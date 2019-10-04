#!/bin/bash

echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'
echo -e '#              Yet-Another-Bench-Script              #'
echo -e '#                     v2019-10-03                    #'
echo -e '# https://github.com/masonr/yet-another-bench-script #'
echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'

echo -e
date

echo -e 
echo -e "Basic System Information:"
echo -e "---------------------------------"
CPU_PROC=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
echo -e "Processor  : $CPU_PROC"
CPU_CORES=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
CPU_FREQ=$(awk -F: ' /cpu MHz/ {freq=$2} END {print freq " MHz"}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
echo -e "CPU cores  : $CPU_CORES @ $CPU_FREQ"
CPU_AES=$(cat /proc/cpuinfo | grep aes)
[[ -z "$CPU_AES" ]] && CPU_AES="\xE2\x9D\x8C Disabled" || CPU_AES="\xE2\x9C\x94 Enabled"
echo -e "AES-NI     : $CPU_AES"
CPU_VIRT=$(cat /proc/cpuinfo | grep 'vmx|svm')
[[ -z "$CPU_VIRT" ]] && CPU_VIRT="\xE2\x9D\x8C Disabled" || CPU_VIRT="\xE2\x9C\x94 Enabled"
echo -e "VM-x/AMD-V : $CPU_VIRT"
TOTAL_RAM=$(free -h | awk 'NR==2 {print $2}')
echo -e "RAM        : $TOTAL_RAM"
TOTAL_SWAP=$(free -h | grep Swap | awk '{ print $2 }')
echo -e "Swap       : $TOTAL_SWAP"
TOTAL_DISK=$(df -t simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total -h | grep total | awk '{ print $2 }')
echo -e "Disk       : $TOTAL_DISK"

DATE=`date -Iseconds | sed -e "s/:/_/g"`
IPERF_PATH=/tmp/$DATE/iperf
mkdir -p $IPERF_PATH
curl -s -o $IPERF_PATH/libiperf.so.0 https://iperf.fr/download/ubuntu/libiperf.so.0_3.1.3 > /dev/null
curl -s -o $IPERF_PATH/iperf3 https://iperf.fr/download/ubuntu/iperf3_3.1.3 > /dev/null
chmod +x $IPERF_PATH/iperf3

function iperf_test {
	URL=$1
	PORTS=$2
	
	I=0
	while [ $I -lt 10 ]
	do
		PORT=`shuf -i $PORTS -n 1`
		IPERF_RUN_SEND="$(LD_LIBRARY_PATH=$IPERF_PATH timeout 15 $IPERF_PATH/iperf3 -c $URL -p $PORT -P 8)"
		if [[ "$IPERF_RUN_SEND" == *"receiver"* && "$IPERF_RUN_SEND" != *"error"* ]]; then
			SPEED=$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver | awk '{ print $6 }')
			[[ -z $SPEED || "$SPEED" == "0.00" ]] && I=$(( $I + 1 )) || I=10
		else
			I=$(( $I + 1 ))
			sleep 2
		fi
	done

	J=0
	while [ $J -lt 10 ]
	do
		PORT=`shuf -i $PORTS -n 1`
		IPERF_RUN_RECV="$(LD_LIBRARY_PATH=$IPERF_PATH timeout 15 $IPERF_PATH/iperf3 -c $URL -p $PORT -P 8 -R)"
		if [[ "$IPERF_RUN_RECV" == *"receiver"* && "$IPERF_RUN_RECV" != *"error"* ]]; then
			SPEED=$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver | awk '{ print $6 }')
			[[ -z $SPEED || "$SPEED" == "0.00" ]] && J=$(( $J + 1 )) || J=10
		else
			J=$(( $J + 1 ))
			sleep 2
		fi
	done

	IPERF_SENDRESULT="$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver)"
	IPERF_RECVRESULT="$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver)"
}

IPERF_LOCS=( \
	"bouygues.iperf.fr" "5200-5209" "Bouygues Telecom" "Paris, FR (10G)" \
	"ping.online.net" "5200-5209" "Online.net" "Paris, FR (10G)" \
	"speedtest.serverius.net" "5002-5002" "Severius" "The Netherlands (10G)" \
	"iperf.worldstream.nl" "5201-5201" "Worldstream" "The Netherlands (10G)" \
	"speedtest.wtnet.de" "5200-5209" "wilhelm.tel" "Hamburg, DE (10G)" \
	"iperf.biznetnetworks.com" "5201-5203" "Biznet" "Bogor, Indonesia (1G)" \
	"speedtest.hostkey.ru" "5200-5203" "Hostkey" "Moscow, RU (1G)" \
	"iperf3.velocityonline.net" "5201-5210" "Velocity Online" "Tallahassee, FL, US (?G)" \
	"iperf.airstreamcomm.net" "5201-5205" "Airstream Communications" "Eau Claire, WI, US (10G)" \
	"iperf.he.net" "5201-5201" "Hurricane Electric" "Fremont, CA, US (1G)" \
)
IPERF_LOCS_NUM=${#IPERF_LOCS[@]}
IPERF_LOCS_NUM=$((IPERF_LOCS_NUM / 4))

echo -e
echo -e "iperf3 Speed Tests:"
echo -e "---------------------------------"
printf "%-25s | %-25s | %-15s | %-15s\n" "Provider" "Location (Link)" "Send Speed" "Recv Speed"
printf "%-25s | %-25s | %-15s | %-15s\n"

for (( i = 0; i < IPERF_LOCS_NUM; i++ )); do
	iperf_test "${IPERF_LOCS[i*4]}" "${IPERF_LOCS[i*4+1]}"
	IPERF_SENDRESULT_VAL=$(echo $IPERF_SENDRESULT | awk '{ print $6 }')
	IPERF_SENDRESULT_UNIT=$(echo $IPERF_SENDRESULT | awk '{ print $7 }')
	IPERF_RECVRESULT_VAL=$(echo $IPERF_RECVRESULT | awk '{ print $6 }')
	IPERF_RECVRESULT_UNIT=$(echo $IPERF_RECVRESULT | awk '{ print $7 }')
	[ -z "$IPERF_SENDRESULT_VAL" ] && IPERF_SENDRESULT_VAL="busy"
	[ -z "$IPERF_RECVRESULT_VAL" ] && IPERF_RECVRESULT_VAL="busy"
	printf "%-25s | %-25s | %-15s | %-15s\n" "${IPERF_LOCS[i*4+2]}" "${IPERF_LOCS[i*4+3]}" "$IPERF_SENDRESULT_VAL $IPERF_SENDRESULT_UNIT" "$IPERF_RECVRESULT_VAL $IPERF_RECVRESULT_UNIT"
done

echo -e
rm -rf /tmp/$DATE

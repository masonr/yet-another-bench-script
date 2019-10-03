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
echo -e "Processor: $CPU_PROC"
CPU_CORES=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
CPU_FREQ=$(awk -F: ' /cpu MHz/ {freq=$2} END {print freq " MHz"}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
echo -e "CPU cores: $CPU_CORES @ $CPU_FREQ"
TOTAL_RAM=$(free -h | awk 'NR==2 {print $2}')
echo -e "RAM      : $TOTAL_RAM"

DATE=`date -Iseconds`
IPERF_PATH=/tmp/$DATE/iperf
mkdir -p $IPERF_PATH
wget -O $IPERF_PATH/libiperf.so.0 https://iperf.fr/download/ubuntu/libiperf.so.0_3.1.3 -o /dev/null
wget -O $IPERF_PATH/iperf3 https://iperf.fr/download/ubuntu/iperf3_3.1.3 -o /dev/null
chmod +x $IPERF_PATH/iperf3

function iperf_test {
	URL=$1
	
	I=0
	while [ $I -lt 10 ]
	do
		IPERF_RUN_SEND="$($IPERF_PATH/iperf3 -c $URL -P 8)"
		if [[ "$IPERF_RUN_SEND" != *"error"* ]]; then
			I=10
			#echo "iperf Send Success!!" # debug
		else
			I=$(( $I + 1 ))
			#echo "iperf Send Failure..." # debug
			sleep 3
		fi
	done

	J=0
	while [ $J -lt 10 ]
	do
		IPERF_RUN_RECV="$($IPERF_PATH/iperf3 -c $URL -P 8 -R)"
		if [[ "$IPERF_RUN_SEND" != *"error"* ]]; then
			J=10
		else
			J=$(( $I + 1 ))
			sleep 3
		fi
	done

	IPERF_SENDRESULT="$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver)"
	IPERF_RECVRESULT="$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver)"
}

IPERF_LOCS=( \
	"bouygues.iperf.fr" "Bouygues Telecom" "Paris, FR (10G)" \
	"ping.online.net" "Online.net" "Paris, FR (10G)" \
	"speedtest.serverius.net -p 5002" "Severius" "Netherlands (10G)" \
	"iperf.worldstream.nl" "Worldstream" "Netherlands (10G)" \
	"speedtest.wtnet.de" "wilhelm.tel" "Hamburg, DE (10G)" \
	"iperf.biznetnetworks.com" "Biznet" "Bogor, ID (1G)" \
	"iperf3.velocityonline.net" "Velocity Online" "Tallahassee, FL, US (?G)" \
	"iperf.airstreamcomm.net" "Airstream Communications" "Eau Claire, WI, US (10G)" \
	"iperf.he.net" "Hurricane Electric" "Fremont, CA, US (1G)" \
)
IPERF_LOCS_NUM=${#IPERF_LOCS[@]}
IPERF_LOCS_NUM=$((IPERF_LOCS_NUM / 3))

echo -e
echo -e "iperf3 Speed Tests:"
echo -e "---------------------------------"
printf "%-25s | %-25s | %-15s | %-15s\n" "Provider" "Location (Link)" "Send Speed" "Recv Speed"
printf "%-25s | %-25s | %-15s | %-15s\n"

for (( i = 0; i < IPERF_LOCS_NUM; i++ )); do
	iperf_test "${IPERF_LOCS[i*3]}"
	IPERF_SENDRESULT_VAL=$(echo $IPERF_SENDRESULT | awk '{ print $6 }')
	IPERF_SENDRESULT_UNIT=$(echo $IPERF_SENDRESULT | awk '{ print $7 }')
	IPERF_RECVRESULT_VAL=$(echo $IPERF_RECVRESULT | awk '{ print $6 }')
	IPERF_RECVRESULT_UNIT=$(echo $IPERF_RECVRESULT | awk '{ print $7 }')
	[ -z "$IPERF_SENDRESULT_VAL" ] && IPERF_SENDRESULT_VAL="busy"
	[ -z "$IPERF_RECVRESULT_VAL" ] && IPERF_RECVRESULT_VAL="busy"
	printf "%-25s | %-25s | %-15s | %-15s\n" "${IPERF_LOCS[i*3+1]}" "${IPERF_LOCS[i*3+2]}" "$IPERF_SENDRESULT_VAL $IPERF_SENDRESULT_UNIT" "$IPERF_RECVRESULT_VAL $IPERF_RECVRESULT_UNIT"
done

echo -e
rm -rf /tmp/$DATE

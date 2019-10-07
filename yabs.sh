#!/bin/bash

echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'
echo -e '#              Yet-Another-Bench-Script              #'
echo -e '#                     v2019-10-06                    #'
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
YABS_PATH=/tmp/$DATE/
mkdir -p $YABS_PATH

SKIP_DD=""
SKIP_IPERF=""
SKIP_GEEKBENCH=""

while getopts 'dig' flag; do
	case "${flag}" in
		d) SKIP_DD="True" ;;
		i) SKIP_IPERF="True" ;;
		g) SKIP_GEEKBENCH="True" ;;
		*) exit 1 ;;
	esac
done

function dd_test {
	I=0
	DD_WRITE_TEST_RES=()
	DD_READ_TEST_RES=()
	DD_WRITE_TEST_AVG=0
	DD_READ_TEST_AVG=0
	OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	while [ $I -lt 3 ]
	do
		DD_WRITE_TEST=$(dd if=/dev/zero of=$DATE.test bs=64k count=16k oflag=direct |& grep copied)
		[[ "$OS" == *"CentOS"* ]] && DD_WRITE_TEST=$(echo $DD_WRITE_TEST | awk '{ print $8 " " $9 }') || DD_WRITE_TEST=$(echo $DD_WRITE_TEST | awk '{ print $10 " " $11 }')
		DD_WRITE_TEST_RES+=( "$DD_WRITE_TEST" )
		VAL=$(echo $DD_WRITE_TEST | cut -d " " -f 1)
		[[ "$DD_WRITE_TEST" == *"GB"* ]] && VAL=$(awk -v a="$VAL" 'BEGIN { print a * 1000 }')
		DD_WRITE_TEST_AVG=$(awk -v a="$DD_WRITE_TEST_AVG" -v b="$VAL" 'BEGIN { print a + b }')
	
		DD_READ_TEST=$(dd if=$DATE.test of=/dev/null bs=64k |& grep copied)
		[[ "$OS" == *"CentOS"* ]] && DD_READ_TEST=$(echo $DD_READ_TEST | awk '{ print $8 " " $9 }') || DD_READ_TEST=$(echo $DD_READ_TEST | awk '{ print $10 " " $11 }')
		DD_READ_TEST_RES+=( "$DD_READ_TEST" )
		VAL=$(echo $DD_READ_TEST | cut -d " " -f 1)
		[[ "$DD_READ_TEST" == *"GB"* ]] && VAL=$(awk -v a="$VAL" 'BEGIN { print a * 1000 }')
		DD_READ_TEST_AVG=$(awk -v a="$DD_READ_TEST_AVG" -v b="$VAL" 'BEGIN { print a + b }')

		I=$(( $I + 1 ))
	done	
	DD_WRITE_TEST_AVG=$(awk -v a="$DD_WRITE_TEST_AVG" 'BEGIN { print a / 3 }')
	DD_READ_TEST_AVG=$(awk -v a="$DD_READ_TEST_AVG" 'BEGIN { print a / 3 }')
}

if [ -z "$SKIP_DD" ]; then
	echo -e "Performing dd disk performance test. This may take a couple minutes to complete..."
	
	touch $DATE.test 2> /dev/null
	if [ -f "$DATE.test" ]; then
		dd_test
		rm $DATE.test
	
		if [ $(echo $DD_WRITE_TEST_AVG | cut -d "." -f 1) -ge 1000 ]; then
			DD_WRITE_TEST_AVG=$(awk -v a="$DD_WRITE_TEST_AVG" 'BEGIN { print a / 1000 }')
			DD_WRITE_TEST_UNIT="GB/s"
		else
			DD_WRITE_TEST_UNIT="MB/s"
		fi
		if [ $(echo $DD_READ_TEST_AVG | cut -d "." -f 1) -ge 1000 ]; then
			DD_READ_TEST_AVG=$(awk -v a="$DD_READ_TEST_AVG" 'BEGIN { print a / 1000 }')
			DD_READ_TEST_UNIT="GB/s"
		else
			DD_READ_TEST_UNIT="MB/s"
		fi
	
		echo -en "\e[1A"; echo -e "\e[0K\r"
		echo -e "dd Disk Speed Tests:"
		echo -e "---------------------------------"
		printf "%-6s | %-10s | %-10s | %-10s | %-10s\n" " " "Test 1" "Test 2" "Test 3" "Avg"
		printf "%-6s | %-10s | %-10s | %-10s | %-10s\n"
		printf "%-6s | %-10s | %-10s | %-10s | %-10s\n" "Write" "${DD_WRITE_TEST_RES[0]}" "${DD_WRITE_TEST_RES[1]}" "${DD_WRITE_TEST_RES[2]}" "${DD_WRITE_TEST_AVG} ${DD_WRITE_TEST_UNIT}" 
		printf "%-6s | %-10s | %-10s | %-10s | %-10s\n" "Read*" "${DD_READ_TEST_RES[0]}" "${DD_READ_TEST_RES[1]}" "${DD_READ_TEST_RES[2]}" "${DD_READ_TEST_AVG} ${DD_READ_TEST_UNIT}" 
	
	else
		echo -en "\e[1A"; echo -e "\e[0K\r"
		echo -e "You do not have write permission in this directory\nSwitch to a different directory to test disk speed.\nSkipping dd tests."
	fi
fi

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
			[[ "$IPERF_RUN_SEND" == *"unable to connect"* ]] && I=10 || I=$(( $I + 1 )) && sleep 2
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
			[[ "$IPERF_RUN_RECV" == *"unable to connect"* ]] && J=10 || J=$(( $J + 1 )) && sleep 2
		fi
	done

	IPERF_SENDRESULT="$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver)"
	IPERF_RECVRESULT="$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver)"
}

function launch_iperf {
	MODE=$1	

	echo -e
	echo -e "iperf3 Network Speed Tests ($MODE):"
	echo -e "---------------------------------"
	printf "%-25s | %-25s | %-15s | %-15s\n" "Provider" "Location (Link)" "Send Speed" "Recv Speed"
	printf "%-25s | %-25s | %-15s | %-15s\n"
	
	for (( i = 0; i < IPERF_LOCS_NUM; i++ )); do
		if [[ "${IPERF_LOCS[i*5+4]}" == *"$MODE"* ]]; then
			echo -e "Performing $MODE iperf3 test to ${IPERF_LOCS[i*5+2]}..."
			iperf_test "${IPERF_LOCS[i*5]}" "${IPERF_LOCS[i*5+1]}"
			echo -en "\e[1A"
			IPERF_SENDRESULT_VAL=$(echo $IPERF_SENDRESULT | awk '{ print $6 }')
			IPERF_SENDRESULT_UNIT=$(echo $IPERF_SENDRESULT | awk '{ print $7 }')
			IPERF_RECVRESULT_VAL=$(echo $IPERF_RECVRESULT | awk '{ print $6 }')
			IPERF_RECVRESULT_UNIT=$(echo $IPERF_RECVRESULT | awk '{ print $7 }')
			[ -z "$IPERF_SENDRESULT_VAL" ] && IPERF_SENDRESULT_VAL="busy"
			[ -z "$IPERF_RECVRESULT_VAL" ] && IPERF_RECVRESULT_VAL="busy"
			printf "%-25s | %-25s | %-15s | %-15s\n" "${IPERF_LOCS[i*5+2]}" "${IPERF_LOCS[i*5+3]}" "$IPERF_SENDRESULT_VAL $IPERF_SENDRESULT_UNIT" "$IPERF_RECVRESULT_VAL $IPERF_RECVRESULT_UNIT"
		fi
	done
}

if [ -z "$SKIP_IPERF" ]; then
	IPERF_PATH=$YABS_PATH/iperf
	mkdir -p $IPERF_PATH
	curl -s -o $IPERF_PATH/libiperf.so.0 https://iperf.fr/download/ubuntu/libiperf.so.0_3.1.3 > /dev/null
	curl -s -o $IPERF_PATH/iperf3 https://iperf.fr/download/ubuntu/iperf3_3.1.3 > /dev/null
	chmod +x $IPERF_PATH/iperf3
	
	PING_FLAG=$(man ping | grep -- " -4")
	[ -z "$PING_FLAG" ] && IPV4_CHECK=$(ping -c 1 -W 4 google.com 2> /dev/null) || IPV4_CHECK=$(ping -c 1 -W 4 -4 google.com 2> /dev/null)
	[[ "$IPV4_CHECK" == *"1 received"* ]] && IPV4_CHECK="True" || IPV4_CHECK=""
	[ -z "$PING_FLAG" ] && IPV6_CHECK=$(ping6 -c 1 -W 4 ipv6.google.com 2> /dev/null) || IPV6_CHECK=$(ping -c 1 -W 4 -6 ipv6.google.com 2> /dev/null)
	[[ "$IPV6_CHECK" == *"1 received"* ]] && IPV6_CHECK="True" || IPV6_CHECK=""
	
	IPERF_LOCS=( \
		"bouygues.iperf.fr" "5200-5209" "Bouygues Telecom" "Paris, FR (10G)" "IPv4|IPv6" \
		"ping.online.net" "5200-5209" "Online.net" "Paris, FR (10G)" "IPv4" \
		"ping6.online.net" "5200-5209" "Online.net" "Paris, FR (10G)" "IPv6" \
		"speedtest.serverius.net" "5002-5002" "Severius" "The Netherlands (10G)" "IPv4|IPv6" \
		"iperf.worldstream.nl" "5201-5201" "Worldstream" "The Netherlands (10G)" "IPv4|IPv6" \
		"speedtest.wtnet.de" "5200-5209" "wilhelm.tel" "Hamburg, DE (10G)" "IPv4|IPv6" \
		"iperf.biznetnetworks.com" "5201-5203" "Biznet" "Bogor, Indonesia (1G)" "IPv4" \
		"speedtest.hostkey.ru" "5200-5203" "Hostkey" "Moscow, RU (1G)" "IPv4" \
		"iperf3.velocityonline.net" "5201-5210" "Velocity Online" "Tallahassee, FL, US (1G)" "IPv4" \
		"iperf.airstreamcomm.net" "5201-5205" "Airstream Communications" "Eau Claire, WI, US (10G)" "IPv4|IPv6" \
		"iperf.he.net" "5201-5201" "Hurricane Electric" "Fremont, CA, US (1G)" "IPv4|IPv6" \
	)
	
	IPERF_LOCS_NUM=${#IPERF_LOCS[@]}
	IPERF_LOCS_NUM=$((IPERF_LOCS_NUM / 5))
	
	[ -z "$IPv4_CHECK" ] && launch_iperf "IPv4"
	[ -z "$IPv6_CHECK" ] && launch_iperf "IPv6"
fi

if [ -z "$SKIP_GEEKBENCH" ]; then
	echo -e "Performing Geekbench 4 benchmark test. This may take a couple minutes to complete..."
	
	GEEKBENCH_PATH=$YABS_PATH/geekbench
	mkdir -p $GEEKBENCH_PATH
	curl -s http://cdn.geekbench.com/Geekbench-4.3.3-Linux.tar.gz  | tar xz --strip-components=1 -C $GEEKBENCH_PATH
	GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench4 | grep "https://browser")
	GEEKBENCH_URL=$(echo -e $GEEKBENCH_TEST | head -1)
	GEEKBENCH_URL_CLAIM=$(echo $GEEKBENCH_URL | awk '{ print $2 }')
	GEEKBENCH_URL=$(echo $GEEKBENCH_URL | awk '{ print $1 }')
	sleep 10
	GEEKBENCH_SCORES=$(curl -s $GEEKBENCH_URL | grep "class='score' rowspan")
	GEEKBENCH_SCORES_SINGLE=$(echo $GEEKBENCH_SCORES | awk -v FS="(>|<)" '{ print $3 }')
	GEEKBENCH_SCORES_MULTI=$(echo $GEEKBENCH_SCORES | awk -v FS="(<|>)" '{ print $7 }')
	
	echo -en "\e[1A"; echo -e "\e[0K\r"
	echo -e "Geekbench 4 Benchmark Test:"
	echo -e "---------------------------------"
	printf "%-15s | %-30s\n" "Test" "Value"
	printf "%-15s | %-30s\n"
	printf "%-15s | %-30s\n" "Single Core" "$GEEKBENCH_SCORES_SINGLE"
	printf "%-15s | %-30s\n" "Multi Core" "$GEEKBENCH_SCORES_MULTI"
	printf "%-15s | %-30s\n" "Full Test" "$GEEKBENCH_URL"
	[ ! -z "$GEEKBENCH_URL_CLAIM" ] && echo -e "$GEEKBENCH_URL_CLAIM" > geekbench4_claim.url 2> /dev/null
fi

echo -e
rm -rf /tmp/$DATE

#!/bin/bash

# Yet Another Bench Script by Mason Rowe
# Initial Oct 2019; Updated Feb 2020
#
# Disclaimer: This project is a work in progress. Any errors or suggestions should be
#             relayed to me via the GitHub project page linked below.
#
# Purpose:    The purpose of this script is to quickly gauge the performance of a Linux-
#             based server by benchmarking network performance via iperf3, CPU and
#             overall system performance via Geekbench 4, and sequential + random  disk
#             performance via fio. The script is designed to not require any dependencies
#             - either compiled or installed - nor admin privileges to run.
#

echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'
echo -e '#              Yet-Another-Bench-Script              #'
echo -e '#                     v2020-02-04                    #'
echo -e '# https://github.com/masonr/yet-another-bench-script #'
echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'

echo -e
date

# override locale to eliminate parsing errors (i.e. using commas a delimiters rather than periods)
export LC_ALL=C

# determine architecture of host
ARCH=$(uname -m)
if [[ $ARCH = *x86_64* ]]; then
	# host is running a 64-bit kernel
	ARCH="x64"
elif [[ $ARCH = *i?86* ]]; then
	# host is running a 32-bit kernel
	ARCH="x86"
else
	# host is running a non-supported kernel
	echo -e "Architecture not supported by YABS."
	exit 1
fi

# gather basic system information (inc. CPU, AES-NI/virt status, RAM + swap + disk size)
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
CPU_VIRT=$(cat /proc/cpuinfo | grep 'vmx\|svm')
[[ -z "$CPU_VIRT" ]] && CPU_VIRT="\xE2\x9D\x8C Disabled" || CPU_VIRT="\xE2\x9C\x94 Enabled"
echo -e "VM-x/AMD-V : $CPU_VIRT"
TOTAL_RAM=$(free -h | awk 'NR==2 {print $2}')
echo -e "RAM        : $TOTAL_RAM"
TOTAL_SWAP=$(free -h | grep Swap | awk '{ print $2 }')
echo -e "Swap       : $TOTAL_SWAP"
# total disk size is calculated by adding all partitions of the types listed below (after the -t flags)
TOTAL_DISK=$(df -t simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total -h | grep total | awk '{ print $2 }')
echo -e "Disk       : $TOTAL_DISK"

# create a directory in the same location that the script is being run to temporarily store YABS-related files
DATE=`date -Iseconds | sed -e "s/:/_/g"`
YABS_PATH=./$DATE
touch $DATE.test 2> /dev/null
# test if the user has write permissions in the current directory and exit if not
if [ ! -f "$DATE.test" ]; then
	echo -e
	echo -e "You do not have write permission in this directory. Switch to an owned directory and re-run the script.\nExiting..."
	exit 1
fi
rm $DATE.test
mkdir -p $YABS_PATH

# flags to skip certain performance tests
SKIP_FIO=""
SKIP_IPERF=""
SKIP_GEEKBENCH=""

# get any arguments that were passed to the script and set the associated skip flags (if applicable)
while getopts 'fdig' flag; do
	case "${flag}" in
		f) SKIP_FIO="True" ;;
		d) SKIP_FIO="True" ;;
		i) SKIP_IPERF="True" ;;
		g) SKIP_GEEKBENCH="True" ;;
		*) exit 1 ;;
	esac
done

# test if the host has IPv4/IPv6 connectivity
IPV4_CHECK=$(curl -s -4 -m 4 icanhazip.com 2> /dev/null)
IPV6_CHECK=$(curl -s -6 -m 4 icanhazip.com 2> /dev/null)

# format_speed
# Purpose: This method is a convienence function to format the output of the fio disk tests which
#          always returns a result in KB/s. If result is >= 1 GB/s, use GB/s. If result is < 1 GB/s
#          and >= 1 MB/s, then use MB/s. Otherwise, use KB/s.
# Parameters:
#          1. RAW - the raw disk speed result (in KB/s)
# Returns:
#          Formatted disk speed in GB/s, MB/s, or KB/s
function format_speed {
	RAW=$1 # disk speed in KB/s
	RESULT=$RAW
	local DENOM=1
	local UNIT="KB/s"

	# ensure raw value is not null, if it is, return blank
        if [ -z "$RAW" ]; then
                echo ""
                return 0
        fi

	# check if disk speed >= 1 GB/s
	if [ "$RAW" -ge 1000000 ]; then
		DENOM=1000000
		UNIT="GB/s"
	# check if disk speed < 1 GB/s && >= 1 MB/s
	elif [ "$RAW" -ge 1000 ]; then
		DENOM=1000
		UNIT="MB/s"
	fi

	# divide the raw result to get the corresponding formatted result (based on determined unit)
	RESULT=$(awk -v a="$RESULT" -v b="$DENOM" 'BEGIN { print a / b }')
	# shorten the formatted result to two decimal places (i.e. x.xx)
	RESULT=$(echo $RESULT | awk -F. '{ printf "%0.2f",$1"."substr($2,1,2) }')
	# concat formatted result value with units and return result
	RESULT="$RESULT $UNIT"
	echo $RESULT
}

# format_iops
# Purpose: This method is a convienence function to format the output of the raw IOPS result
# Parameters:
#          1. RAW - the raw IOPS result
# Returns:
#          Formatted IOPS (i.e. 8, 123, 1.7k, 275.9k, etc.)
function format_iops {
	RAW=$1 # iops
	RESULT=$RAW

	# ensure raw value is not null, if it is, return blank
	if [ -z "$RAW" ]; then
		echo ""
		return 0
	fi

	# check if IOPS speed > 1k
	if [ "$RAW" -ge 1000 ]; then
		# divide the raw result by 1k
		RESULT=$(awk -v a="$RESULT" 'BEGIN { print a / 1000 }')
		# shorten the formatted result to one decimal place (i.e. x.x)
		RESULT=$(echo $RESULT | awk -F. '{ printf "%0.1f",$1"."substr($2,1,1) }')
		RESULT="$RESULT"k
	fi

	echo $RESULT
}

# disk_test
# Purpose: This method is designed to test the disk performance of the host using the partition that the
#          script is being run from using fio sequential and random read/write speed tests.
# Parameters:
#          - (none)
function disk_test {
	# run a quick test to generate the fio test file to be used by the actual tests
	echo -en "Generating fio test file..."
	$DISK_PATH/fio --name=setup --ioengine=libaio --rw=read --bs=4k --iodepth=64 --numjobs=2 --size=2G --runtime=1 --gtod_reduce=1 --filename=$DISK_PATH/test.fio --direct=1 --minimal &> /dev/null
	echo -en "\r\033[0K"

	# run rand read/write mixed 4kb fio test
	echo -en "Running fio random mixed read + write disk test with 4kb blocks..."
	DISK_RW4_TEST=$(timeout 35 $DISK_PATH/fio --name=rand_rw_4k --ioengine=libaio --rw=randrw --rwmixread=50 --bs=4k --iodepth=64 --numjobs=2 --size=2G --runtime=30 --gtod_reduce=1 --direct=1 --filename=$DISK_PATH/test.fio --group_reporting --minimal 2> /dev/null | grep rand_rw_4k)
	DISK_RW4_IOPS_R=$(echo $DISK_RW4_TEST | awk -F';' '{print $8}')
	DISK_RW4_IOPS_W=$(echo $DISK_RW4_TEST | awk -F';' '{print $49}')
	DISK_RW4_IOPS=$(format_iops $(awk -v a="$DISK_RW4_IOPS_R" -v b="$DISK_RW4_IOPS_W" 'BEGIN { print a + b }'))
	DISK_RW4_IOPS_R=$(format_iops $DISK_RW4_IOPS_R)
	DISK_RW4_IOPS_W=$(format_iops $DISK_RW4_IOPS_W)
	DISK_RW4_TEST_R=$(echo $DISK_RW4_TEST | awk -F';' '{print $7}')
	DISK_RW4_TEST_W=$(echo $DISK_RW4_TEST | awk -F';' '{print $48}')
	DISK_RW4_TEST=$(format_speed $(awk -v a="$DISK_RW4_TEST_R" -v b="$DISK_RW4_TEST_W" 'BEGIN { print a + b }'))
	DISK_RW4_TEST_R=$(format_speed $DISK_RW4_TEST_R)
	DISK_RW4_TEST_W=$(format_speed $DISK_RW4_TEST_W)
	echo -en "\r\033[0K"

	# run rand read/write mixed 64kb fio test
        echo -en "Running fio random mixed read + write disk test with 64kb blocks..."
        DISK_RW64_TEST=$(timeout 35 $DISK_PATH/fio --name=rand_rw_64k --ioengine=libaio --rw=randrw --rwmixread=50 --bs=64k --iodepth=64 --numjobs=2 --size=2G --runtime=30 --gtod_reduce=1 --direct=1 --filename=$DISK_PATH/test.fio --group_reporting --minimal 2> /dev/null | grep rand_rw_64k)
        DISK_RW64_IOPS_R=$(echo $DISK_RW64_TEST | awk -F';' '{print $8}')
        DISK_RW64_IOPS_W=$(echo $DISK_RW64_TEST | awk -F';' '{print $49}')
        DISK_RW64_IOPS=$(format_iops $(awk -v a="$DISK_RW64_IOPS_R" -v b="$DISK_RW64_IOPS_W" 'BEGIN { print a + b }'))
	DISK_RW64_IOPS_R=$(format_iops $DISK_RW64_IOPS_R)
	DISK_RW64_IOPS_W=$(format_iops $DISK_RW64_IOPS_W)
        DISK_RW64_TEST_R=$(echo $DISK_RW64_TEST | awk -F';' '{print $7}')
        DISK_RW64_TEST_W=$(echo $DISK_RW64_TEST | awk -F';' '{print $48}')
        DISK_RW64_TEST=$(format_speed $(awk -v a="$DISK_RW64_TEST_R" -v b="$DISK_RW64_TEST_W" 'BEGIN { print a + b }'))
	DISK_RW64_TEST_R=$(format_speed $DISK_RW64_TEST_R)
	DISK_RW64_TEST_W=$(format_speed $DISK_RW64_TEST_W)
        echo -en "\r\033[0K"

	# run rand read/write mixed 512kb fio test
        echo -en "Running fio random mixed read + write disk test with 512kb blocks..."
        DISK_RW512_TEST=$(timeout 35 $DISK_PATH/fio --name=rand_rw_512k --ioengine=libaio --rw=randrw --rwmixread=50 --bs=512k --iodepth=64 --numjobs=2 --size=2G --runtime=30 --gtod_reduce=1 --direct=1 --filename=$DISK_PATH/test.fio --group_reporting --minimal 2> /dev/null | grep rand_rw_512k)
        DISK_RW512_IOPS_R=$(echo $DISK_RW512_TEST | awk -F';' '{print $8}')
        DISK_RW512_IOPS_W=$(echo $DISK_RW512_TEST | awk -F';' '{print $49}')
        DISK_RW512_IOPS=$(format_iops $(awk -v a="$DISK_RW512_IOPS_R" -v b="$DISK_RW512_IOPS_W" 'BEGIN { print a + b }'))
        DISK_RW512_IOPS_R=$(format_iops $DISK_RW512_IOPS_R)
        DISK_RW512_IOPS_W=$(format_iops $DISK_RW512_IOPS_W)
        DISK_RW512_TEST_R=$(echo $DISK_RW512_TEST | awk -F';' '{print $7}')
        DISK_RW512_TEST_W=$(echo $DISK_RW512_TEST | awk -F';' '{print $48}')
        DISK_RW512_TEST=$(format_speed $(awk -v a="$DISK_RW512_TEST_R" -v b="$DISK_RW512_TEST_W" 'BEGIN { print a + b }'))
        DISK_RW512_TEST_R=$(format_speed $DISK_RW512_TEST_R)
        DISK_RW512_TEST_W=$(format_speed $DISK_RW512_TEST_W)
        echo -en "\r\033[0K"

	# run rand read/write mixed 1mb fio test
        echo -en "Running fio random mixed read + write disk test with 1mb blocks..."
        DISK_RW1M_TEST=$(timeout 35 $DISK_PATH/fio --name=rand_rw_1m --ioengine=libaio --rw=randrw --rwmixread=50 --bs=1m --iodepth=64 --numjobs=2 --size=2G --runtime=30 --gtod_reduce=1 --direct=1 --filename=$DISK_PATH/test.fio --group_reporting --minimal 2> /dev/null | grep rand_rw_1m)
        DISK_RW1M_IOPS_R=$(echo $DISK_RW1M_TEST | awk -F';' '{print $8}')
        DISK_RW1M_IOPS_W=$(echo $DISK_RW1M_TEST | awk -F';' '{print $49}')
        DISK_RW1M_IOPS=$(format_iops $(awk -v a="$DISK_RW1M_IOPS_R" -v b="$DISK_RW1M_IOPS_W" 'BEGIN { print a + b }'))
        DISK_RW1M_IOPS_R=$(format_iops $DISK_RW1M_IOPS_R)
        DISK_RW1M_IOPS_W=$(format_iops $DISK_RW1M_IOPS_W)
        DISK_RW1M_TEST_R=$(echo $DISK_RW1M_TEST | awk -F';' '{print $7}')
        DISK_RW1M_TEST_W=$(echo $DISK_RW1M_TEST | awk -F';' '{print $48}')
        DISK_RW1M_TEST=$(format_speed $(awk -v a="$DISK_RW1M_TEST_R" -v b="$DISK_RW1M_TEST_W" 'BEGIN { print a + b }'))
        DISK_RW1M_TEST_R=$(format_speed $DISK_RW1M_TEST_R)
        DISK_RW1M_TEST_W=$(format_speed $DISK_RW1M_TEST_W)
        echo -en "\r\033[0K"
}

# if the skip disk flag was set, skip the disk performance test, otherwise test disk performance
if [ -z "$SKIP_FIO" ]; then
	echo -en "\nPreparing system for disk tests..."

	# create temp directory to store disk write/read test files
	DISK_PATH=$YABS_PATH/disk
	mkdir -p $DISK_PATH

	# download fio binary
	if [ ! -z "$IPV4_CHECK" ]; then # if IPv4 is enabled
		curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/bin/fio_$ARCH -o $DISK_PATH/fio
	else # no IPv4, use IPv6 - below is necessary since raw.githubusercontent.com has no AAAA record
		curl -s -k -g --header 'Host: raw.githubusercontent.com' https://[2a04:4e42::133]/masonr/yet-another-bench-script/master/bin/fio_$ARCH -o $DISK_PATH/fio
	fi
	chmod +x $DISK_PATH/fio

	echo -en "\r\033[0K"
	
	# execute disk performance test
	disk_test

	if [ -z "$DISK_RW4_TEST" ]; then # fio was killed or returned an error
		echo -e "fio disk speed tests failed. Run manually to determine cause."
	else # fio tests completed sucessfully, print results
		
		# print disk speed test results
		echo -e "fio Disk Speed Tests (Mixed R/W 50/50):"
		echo -e "---------------------------------"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Block Size" "4kb" "(IOPS)" "64kb" "(IOPS)"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "  ------" "---" "---- " "----" "---- "
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Read" "$DISK_RW4_TEST_R" "($DISK_RW4_IOPS_R)" "$DISK_RW64_TEST_R" "($DISK_RW64_IOPS_R)"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Write" "$DISK_RW4_TEST_W" "($DISK_RW4_IOPS_W)" "$DISK_RW64_TEST_W" "($DISK_RW64_IOPS_W)"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Total" "$DISK_RW4_TEST" "($DISK_RW4_IOPS)" "$DISK_RW64_TEST" "($DISK_RW64_IOPS)"
		printf "%-10s | %-20s | %-20s\n"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Block Size" "512kb" "(IOPS)" "1mb" "(IOPS)"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "  ------" "-----" "---- " "---" "---- "
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Read" "$DISK_RW512_TEST_R" "($DISK_RW512_IOPS_R)" "$DISK_RW1M_TEST_R" "($DISK_RW1M_IOPS_R)"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Write" "$DISK_RW512_TEST_W" "($DISK_RW512_IOPS_W)" "$DISK_RW1M_TEST_W" "($DISK_RW1M_IOPS_W)"
		printf "%-10s | %-11s %8s | %-11s %8s\n" "Total" "$DISK_RW512_TEST" "($DISK_RW512_IOPS)" "$DISK_RW1M_TEST" "($DISK_RW1M_IOPS)"
	fi
fi

# iperf_test
# Purpose: This method is designed to test the network performance of the host by executing an
#          iperf3 test to/from the public iperf server passed to the function. Both directions 
#          (send and recieve) are tested.
# Parameters:
#          1. URL - URL/domain name of the iperf server
#          2. PORTS - the range of ports on which the iperf server operates
#          3. HOST - the friendly name of the iperf server host/owner
#          4. FLAGS - any flags that should be passed to the iperf command
function iperf_test {
	URL=$1
	PORTS=$2
	HOST=$3
	FLAGS=$4
	
	# attempt the iperf send test 10 times, allowing for a slot to become available on the
	#   server or to throw out any bad/error results
	I=1
	while [ $I -le 10 ]
	do
		echo -en "Performing $MODE iperf3 send test to $HOST (Attempt #$I of 10)..."
		# select a random iperf port from the range provided
		PORT=`shuf -i $PORTS -n 1`
		# run the iperf test sending data from the host to the iperf server; includes
		#   a timeout of 15s in case the iperf server is not responding; uses 8 parallel
		#   threads for the network test
		IPERF_RUN_SEND="$(timeout 15 $IPERF_PATH/iperf3 $FLAGS -c $URL -p $PORT -P 8 2> /dev/null)"
		# check if iperf exited cleanly and did not return an error
		if [[ "$IPERF_RUN_SEND" == *"receiver"* && "$IPERF_RUN_SEND" != *"error"* ]]; then
			# test did not result in an error, parse speed result
			SPEED=$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver | awk '{ print $6 }')
			# if speed result is blank or bad (0.00), rerun, otherwise set counter to exit loop
			[[ -z $SPEED || "$SPEED" == "0.00" ]] && I=$(( $I + 1 )) || I=11
		else
			# if iperf server is not responding, set counter to exit, otherwise increment, sleep, and rerun
			[[ "$IPERF_RUN_SEND" == *"unable to connect"* ]] && I=11 || I=$(( $I + 1 )) && sleep 2
		fi
		echo -en "\r\033[0K"
	done

	# small sleep necessary to give iperf server a breather to get ready for a new test
	sleep 1

	# attempt the iperf recieve test 10 times, allowing for a slot to become available on
	#   the server or to throw out any bad/error results
	J=1
	while [ $J -le 10 ]
	do
		echo -n "Performing $MODE iperf3 recv test from $HOST (Attempt #$J of 10)..."
		# select a random iperf port from the range provided
		PORT=`shuf -i $PORTS -n 1`
		# run the iperf test recieving data from the iperf server to the host; includes
		#   a timeout of 15s in case the iperf server is not responding; uses 8 parallel
		#   threads for the network test
		IPERF_RUN_RECV="$(timeout 15 $IPERF_PATH/iperf3 $FLAGS -c $URL -p $PORT -P 8 -R 2> /dev/null)"
		# check if iperf exited cleanly and did not return an error
		if [[ "$IPERF_RUN_RECV" == *"receiver"* && "$IPERF_RUN_RECV" != *"error"* ]]; then
			# test did not result in an error, parse speed result
			SPEED=$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver | awk '{ print $6 }')
			# if speed result is blank or bad (0.00), rerun, otherwise set counter to exit loop
			[[ -z $SPEED || "$SPEED" == "0.00" ]] && J=$(( $J + 1 )) || J=11
		else
			# if iperf server is not responding, set counter to exit, otherwise increment, sleep, and rerun
			[[ "$IPERF_RUN_RECV" == *"unable to connect"* ]] && J=11 || J=$(( $J + 1 )) && sleep 2
		fi
		echo -en "\r\033[0K"
	done

	# parse the resulting send and recieve speed results
	IPERF_SENDRESULT="$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver)"
	IPERF_RECVRESULT="$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver)"
}

# launch_iperf
# Purpose: This method is designed to facilitate the execution of iperf network speed tests to
#          each public iperf server in the iperf server locations array.
# Parameters:
#          1. MODE - indicates the type of iperf tests to run (IPv4 or IPv6)
function launch_iperf {
	MODE=$1
	[[ "$MODE" == *"IPv6"* ]] && IPERF_FLAGS="-6" || IPERF_FLAGS="-4"

	# print iperf3 network speed results as they are completed
	echo -e
	echo -e "iperf3 Network Speed Tests ($MODE):"
	echo -e "---------------------------------"
	printf "%-25s | %-25s | %-15s | %-15s\n" "Provider" "Location (Link)" "Send Speed" "Recv Speed"
	printf "%-25s | %-25s | %-15s | %-15s\n"
	
	# loop through iperf locations array to run iperf test using each public iperf server
	for (( i = 0; i < IPERF_LOCS_NUM; i++ )); do
		# test if the current iperf location supports the network mode being tested (IPv4/IPv6)
		if [[ "${IPERF_LOCS[i*5+4]}" == *"$MODE"* ]]; then
			# call the iperf_test function passing the required parameters
			iperf_test "${IPERF_LOCS[i*5]}" "${IPERF_LOCS[i*5+1]}" "${IPERF_LOCS[i*5+2]}" "$IPERF_FLAGS"
			# parse the send and recieve speed results
			IPERF_SENDRESULT_VAL=$(echo $IPERF_SENDRESULT | awk '{ print $6 }')
			IPERF_SENDRESULT_UNIT=$(echo $IPERF_SENDRESULT | awk '{ print $7 }')
			IPERF_RECVRESULT_VAL=$(echo $IPERF_RECVRESULT | awk '{ print $6 }')
			IPERF_RECVRESULT_UNIT=$(echo $IPERF_RECVRESULT | awk '{ print $7 }')
			# if the results are blank, then the server is "busy" and being overutilized
			[[ -z $IPERF_SENDRESULT_VAL || "$IPERF_SENDRESULT_VAL" == *"0.00"* ]] && IPERF_SENDRESULT_VAL="busy" && IPERF_SENDRESULT_UNIT=""
			[[ -z $IPERF_RECVRESULT_VAL || "$IPERF_RECVRESULT_VAL" == *"0.00"* ]] && IPERF_RECVRESULT_VAL="busy" && IPERF_RECVRESULT_UNIT=""
			# print the speed results for the iperf location currently being evaluated
			printf "%-25s | %-25s | %-15s | %-15s\n" "${IPERF_LOCS[i*5+2]}" "${IPERF_LOCS[i*5+3]}" "$IPERF_SENDRESULT_VAL $IPERF_SENDRESULT_UNIT" "$IPERF_RECVRESULT_VAL $IPERF_RECVRESULT_UNIT"
		fi
	done
}

# if the skip iperf flag was set, skip the network performance test, otherwise test network performance
if [ -z "$SKIP_IPERF" ]; then

	# create a temp directory to house the required iperf binary and library
	IPERF_PATH=$YABS_PATH/iperf
	mkdir -p $IPERF_PATH

	# download iperf3 binary
        if [ ! -z "$IPV4_CHECK" ]; then # if IPv4 is enabled
                curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/bin/iperf3_$ARCH -o $IPERF_PATH/iperf3
        else # no IPv4, use IPv6 - below is necessary since raw.githubusercontent.com has no AAAA record
                curl -s -k -g --header 'Host: raw.githubusercontent.com' https://[2a04:4e42::133]/masonr/yet-another-bench-script/master/bin/iperf3_$ARCH -o $IPERF_PATH/iperf3
        fi

	chmod +x $IPERF_PATH/iperf3
	
	# array containing all currently available iperf3 public servers to use for the network test
	# format: "1" "2" "3" "4" "5" \
	#   1. domain name of the iperf server
	#   2. range of ports that the iperf server is running on (lowest-highest)
	#   3. friendly name of the host/owner of the iperf server
	#   4. location and advertised speed link of the iperf server
	#   5. network modes supported by the iperf server (IPv4 = IPv4-only, IPv4|IPv6 = IPv4 + IPv6, etc.)
	IPERF_LOCS=( \
		"bouygues.iperf.fr" "5200-5209" "Bouygues Telecom" "Paris, FR (10G)" "IPv4|IPv6" \
		"ping.online.net" "5200-5209" "Online.net" "Paris, FR (10G)" "IPv4" \
		"ping6.online.net" "5200-5209" "Online.net" "Paris, FR (10G)" "IPv6" \
		"iperf.worldstream.nl" "5201-5201" "Worldstream" "The Netherlands (10G)" "IPv4|IPv6" \
		"speedtest.wtnet.de" "5200-5209" "wilhelm.tel" "Hamburg, DE (10G)" "IPv4|IPv6" \
		"iperf.biznetnetworks.com" "5201-5203" "Biznet" "Bogor, Indonesia (1G)" "IPv4" \
		"speedtest.hostkey.ru" "5200-5203" "Hostkey" "Moscow, RU (1G)" "IPv4" \
		"iperf3.velocityonline.net" "5201-5210" "Velocity Online" "Tallahassee, FL, US (10G)" "IPv4" \
		"iperf.airstreamcomm.net" "5201-5205" "Airstream Communications" "Eau Claire, WI, US (10G)" "IPv4|IPv6" \
		"iperf.he.net" "5201-5201" "Hurricane Electric" "Fremont, CA, US (10G)" "IPv4|IPv6" \
	)
	
	# get the total number of iperf locations (total array size divided by 5 since each location has 5 elements)
	IPERF_LOCS_NUM=${#IPERF_LOCS[@]}
	IPERF_LOCS_NUM=$((IPERF_LOCS_NUM / 5))
	
	# check if the host has IPv4 connectivity, if so, run iperf3 IPv4 tests
	[ ! -z "$IPV4_CHECK" ] && launch_iperf "IPv4"
	# check if the host has IPv6 connectivity, if so, run iperf3 IPv6 tests
	[ ! -z "$IPV6_CHECK" ] && launch_iperf "IPv6"
fi

# if the skip geekbench flag was set, skip the system performance test, otherwise test system performance
if [ -z "$SKIP_GEEKBENCH" ]; then
	echo -en "\nPerforming Geekbench 4 benchmark test. This may take a couple minutes to complete..."

	# create a temp directory to house all geekbench files
	GEEKBENCH_PATH=$YABS_PATH/geekbench
	mkdir -p $GEEKBENCH_PATH

	# download the latest Geekbench 4 tarball and extract to geekbench temp directory
	curl -s http://cdn.geekbench.com/Geekbench-4.3.3-Linux.tar.gz  | tar xz --strip-components=1 -C $GEEKBENCH_PATH &>/dev/null

	if [[ "$ARCH" == *"x86"* ]]; then
		# run the Geekbench 4 test and grep the test results URL given at the end of the test
                GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench_x86_32 2>/dev/null | grep "https://browser")
	else
		# run the Geekbench 4 test and grep the test results URL given at the end of the test
		GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench4 2>/dev/null | grep "https://browser")
	fi

	# ensure the test ran successfully
	if [ -z "$GEEKBENCH_TEST" ]; then
		if [ -z "$IPV4_CHECK" ]; then
			# Geekbench 4 test failed to download because host lacks IPv4 (cdn.geekbench.com = IPv4 only)
			echo -e "\r\033[0KGeekbench releases can only be downloaded over IPv4. FTP the Geekbench files and run manually."
		else
			# if the Geekbench 4 test failed for any reason, exit cleanly and print error message
			echo -e "\r\033[0KGeekbench 4 test failed. Run manually to determine cause."
		fi
	else
		# if the Geekbench 4 test succeeded, parse the test results URL
		GEEKBENCH_URL=$(echo -e $GEEKBENCH_TEST | head -1)
		GEEKBENCH_URL_CLAIM=$(echo $GEEKBENCH_URL | awk '{ print $2 }')
		GEEKBENCH_URL=$(echo $GEEKBENCH_URL | awk '{ print $1 }')
		# sleep a bit to wait for results to be made available on the geekbench website
		sleep 10
		# parse the public results page for the single and multi core geekench scores
		GEEKBENCH_SCORES=$(curl -s $GEEKBENCH_URL | grep "class='score' rowspan")
		GEEKBENCH_SCORES_SINGLE=$(echo $GEEKBENCH_SCORES | awk -v FS="(>|<)" '{ print $3 }')
		GEEKBENCH_SCORES_MULTI=$(echo $GEEKBENCH_SCORES | awk -v FS="(<|>)" '{ print $7 }')
	
		# print the Geekbench 4 results
		echo -en "\r\033[0K"
		echo -e "Geekbench 4 Benchmark Test:"
		echo -e "---------------------------------"
		printf "%-15s | %-30s\n" "Test" "Value"
		printf "%-15s | %-30s\n"
		printf "%-15s | %-30s\n" "Single Core" "$GEEKBENCH_SCORES_SINGLE"
		printf "%-15s | %-30s\n" "Multi Core" "$GEEKBENCH_SCORES_MULTI"
		printf "%-15s | %-30s\n" "Full Test" "$GEEKBENCH_URL"

		# write the geekbench 4 claim URL to a file so the user can add the results to their profile (if desired)
		[ ! -z "$GEEKBENCH_URL_CLAIM" ] && echo -e "$GEEKBENCH_URL_CLAIM" > geekbench4_claim.url 2> /dev/null
	fi
fi

# finished all tests, clean up all YABS files and exit
echo -e
rm -rf $YABS_PATH

# reset locale settings
unset LC_ALL

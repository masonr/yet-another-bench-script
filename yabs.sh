#!/bin/bash

# Yet Another Bench Script by Mason Rowe
# Initial Oct 2019; Updated Jan 2020
#
# Disclaimer: This project is a work in progress. Any errors or suggestions should be
#             relayed to me via the GitHub project page linked below.
#
# Purpose:    The purpose of this script is to quickly gauge the performance of a Linux-
#             based server by benchmarking network performance via iperf3, CPU and
#             overall system performance via Geekbench 4, and simple sequential disk
#             performance via dd. The script is designed to not require any dependencies
#             - either compiled or installed - nor admin privileges to run.
#

echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'
echo -e '#              Yet-Another-Bench-Script              #'
echo -e '#                     v2020-01-08                    #'
echo -e '# https://github.com/masonr/yet-another-bench-script #'
echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'

echo -e
date

# override locale to eliminate parsing errors (i.e. using commas a delimiters rather than periods)
export LC_ALL=C

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
SKIP_DISK=""
SKIP_IPERF=""
SKIP_GEEKBENCH=""

# get any arguments that were passed to the script and set the associated skip flags (if applicable)
while getopts 'dig' flag; do
	case "${flag}" in
		d) SKIP_DISK="True" ;;
		i) SKIP_IPERF="True" ;;
		g) SKIP_GEEKBENCH="True" ;;
		*) exit 1 ;;
	esac
done

# disk_test
# Purpose: This method is designed to test the disk performance of the host using the partition that the
#          script is being run from using dd sequential speed tests and averaging the results.
# Parameters:
#          - (none)
function disk_test {
	I=0
	DISK_WRITE_TEST_RES=()
	DISK_READ_TEST_RES=()
	DISK_WRITE_TEST_AVG=0
	DISK_READ_TEST_AVG=0

	# run the disk speed tests (write and read) thrice over
	while [ $I -lt 3 ]
	do
		# write test using dd, "direct" flag is used to test direct I/O for data being stored to disk
		DISK_WRITE_TEST=$(dd if=/dev/zero of=$DISK_PATH/$DATE.test bs=64k count=16k oflag=direct |& grep copied | awk '{ print $(NF-1) " " $(NF)}')
		VAL=$(echo $DISK_WRITE_TEST | cut -d " " -f 1)
		[[ "$DISK_WRITE_TEST" == *"GB"* ]] && VAL=$(awk -v a="$VAL" 'BEGIN { print a * 1000 }')
		DISK_WRITE_TEST_RES+=( "$DISK_WRITE_TEST" )
		DISK_WRITE_TEST_AVG=$(awk -v a="$DISK_WRITE_TEST_AVG" -v b="$VAL" 'BEGIN { print a + b }')
	
		# read test using dd using the 1G file written during the write test
		DISK_READ_TEST=$(dd if=$DISK_PATH/$DATE.test of=/dev/null bs=8k |& grep copied | awk '{ print $(NF-1) " " $(NF)}')
		VAL=$(echo $DISK_READ_TEST | cut -d " " -f 1)
		[[ "$DISK_READ_TEST" == *"GB"* ]] && VAL=$(awk -v a="$VAL" 'BEGIN { print a * 1000 }')
		DISK_READ_TEST_RES+=( "$DISK_READ_TEST" )
		DISK_READ_TEST_AVG=$(awk -v a="$DISK_READ_TEST_AVG" -v b="$VAL" 'BEGIN { print a + b }')

		I=$(( $I + 1 ))
	done	
	# calculate the write and read speed averages using the results from the three runs
	DISK_WRITE_TEST_AVG=$(awk -v a="$DISK_WRITE_TEST_AVG" 'BEGIN { print a / 3 }')
	DISK_READ_TEST_AVG=$(awk -v a="$DISK_READ_TEST_AVG" 'BEGIN { print a / 3 }')
}

# if the skip disk flag was set, skip the disk performance test, otherwise test disk performance
if [ -z "$SKIP_DISK" ]; then
	echo -en "\nPerforming disk performance test. This may take a couple minutes to complete..."

	# create temp directory to store disk write/read test files
	DISK_PATH=$YABS_PATH/disk
	mkdir -p $DISK_PATH
	
	# execute disk performance test
	disk_test

	# format the speed averages by converting to GB/s if > 1000 MB/s
	if [ $(echo $DISK_WRITE_TEST_AVG | cut -d "." -f 1) -ge 1000 ]; then
		DISK_WRITE_TEST_AVG=$(awk -v a="$DISK_WRITE_TEST_AVG" 'BEGIN { print a / 1000 }')
		DISK_WRITE_TEST_UNIT="GB/s"
	else
		DISK_WRITE_TEST_UNIT="MB/s"
	fi
	if [ $(echo $DISK_READ_TEST_AVG | cut -d "." -f 1) -ge 1000 ]; then
		DISK_READ_TEST_AVG=$(awk -v a="$DISK_READ_TEST_AVG" 'BEGIN { print a / 1000 }')
		DISK_READ_TEST_UNIT="GB/s"
	else
		DISK_READ_TEST_UNIT="MB/s"
	fi

	# print dd sequential disk speed test results
	echo -en "\r\033[0K"
	echo -e "dd Sequential Disk Speed Tests:"
	echo -e "---------------------------------"
	printf "%-6s | %-6s %-4s | %-6s %-4s | %-6s %-4s | %-6s %-4s\n" "" "Test 1" "" "Test 2" ""  "Test 3" "" "Avg" ""
	printf "%-6s | %-6s %-4s | %-6s %-4s | %-6s %-4s | %-6s %-4s\n"
	printf "%-6s | %-11s | %-11s | %-11s | %-6.2f %-4s\n" "Write" "${DISK_WRITE_TEST_RES[0]}" "${DISK_WRITE_TEST_RES[1]}" "${DISK_WRITE_TEST_RES[2]}" "${DISK_WRITE_TEST_AVG}" "${DISK_WRITE_TEST_UNIT}" 
	printf "%-6s | %-11s | %-11s | %-11s | %-6.2f %-4s\n" "Read" "${DISK_READ_TEST_RES[0]}" "${DISK_READ_TEST_RES[1]}" "${DISK_READ_TEST_RES[2]}" "${DISK_READ_TEST_AVG}" "${DISK_READ_TEST_UNIT}" 
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
		IPERF_RUN_SEND="$(LD_LIBRARY_PATH=$IPERF_PATH timeout 15 $IPERF_PATH/iperf3 $FLAGS -c $URL -p $PORT -P 8)"
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
		IPERF_RUN_RECV="$(LD_LIBRARY_PATH=$IPERF_PATH timeout 15 $IPERF_PATH/iperf3 $FLAGS -c $URL -p $PORT -P 8 -R)"
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
			[[ -z $IPERF_SENDRESULT_VAL || "$IPERF_SENDRESULT_VAL" == *"0.00"* ]] && IPERF_SENDRESULT_VAL="busy"
			[[ -z $IPERF_RECVRESULT_VAL || "$IPERF_RECVRESULT_VAL" == *"0.00"* ]] && IPERF_RECVRESULT_VAL="busy"
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
	# download the publicly available iperf files from project's official source (iperf.fr)
	curl -s -o $IPERF_PATH/libiperf.so.0 https://iperf.fr/download/ubuntu/libiperf.so.0_3.1.3 > /dev/null
	curl -s -o $IPERF_PATH/iperf3 https://iperf.fr/download/ubuntu/iperf3_3.1.3 > /dev/null
	chmod +x $IPERF_PATH/iperf3
	
	# test if the host has IPv4/IPv6 connectivity
	IPV4_CHECK=$(curl -s -4 -m 4 icanhazip.com 2> /dev/null)
	IPV6_CHECK=$(curl -s -6 -m 4 icanhazip.com 2> /dev/null)
	
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
		"speedtest.serverius.net" "5002-5002" "Severius" "The Netherlands (10G)" "IPv4|IPv6" \
		"iperf.worldstream.nl" "5201-5201" "Worldstream" "The Netherlands (10G)" "IPv4|IPv6" \
		"speedtest.wtnet.de" "5200-5209" "wilhelm.tel" "Hamburg, DE (10G)" "IPv4|IPv6" \
		"iperf.biznetnetworks.com" "5201-5203" "Biznet" "Bogor, Indonesia (1G)" "IPv4" \
		"speedtest.hostkey.ru" "5200-5203" "Hostkey" "Moscow, RU (1G)" "IPv4" \
		"mirror.square-r00t.net" "5201-5201" "Vultr" "Piscataway, NJ, US (1G)" "IPv4|IPv6" \
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
	# run the Geekbench 4 test and grep the test results URL given at the end of the test
	GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench4 2>/dev/null | grep "https://browser")

	# ensure the test ran successfully
	if [ -z "$GEEKBENCH_TEST" ]; then
		# if the Geekbench 4 test failed for any reason, exit cleanly and print error message
		echo -e "\r\033[0KGeekbench 4 test failed. Run manually to determine cause."
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

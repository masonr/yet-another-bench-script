#!/bin/bash

echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'
echo -e '#              Yet-Another-Bench-Script              #'
echo -e '#                     v2019-10-02                    #'
echo -e '# https://github.com/masonr/yet-another-bench-script #'
echo -e '# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #'

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
			#echo "iperf Recv Success!!" # debug
		else
			J=$(( $I + 1 ))
			#echo "iperf Recv Failure..." # debug
			sleep 3
		fi
	done

	IPERF_SENDRESULT="$(echo "${IPERF_RUN_SEND}" | grep SUM | grep receiver)"
	IPERF_RECVRESULT="$(echo "${IPERF_RUN_RECV}" | grep SUM | grep receiver)"
}

IPERF_LOCS=("bouygues.iperf.fr" "ping.online.net" )
for loc in ${IPERF_LOCS[@]}; do
	iperf_test $loc	
	echo "Send result: $IPERF_SENDRESULT"
	echo "Recv result: $IPERF_RECVRESULT"
done

# iperf debug
#echo -e "#######################"
#echo -e "${IPERF_RUN_SEND}"
#echo -e "${IPERF_RUN_RECV}"

rm -rf /tmp/$DATE

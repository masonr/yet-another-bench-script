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

I=0
IPERF_RUN_SEND="$($IPERF_PATH/iperf3 -c bouygues.iperf.fr -P 8)"
IPERF_RUN_RECV="$($IPERF_PATH/iperf3 -c bouygues.iperf.fr -P 8 -R)"
echo -e "${IPERF_RUN_SEND}" | grep SUM | grep receiver
echo -e "${IPERF_RUN_RECV}" | grep SUM | grep receiver

# iperf debug
#echo -e "#######################"
#echo -e "${IPERF_RUN_SEND}"
#echo -e "${IPERF_RUN_RECV}"

rm -rf /tmp/$DATE

#!/bin/bash
set -e

# Activate Holy Build Box lib compiliation environment
source /hbb/activate

set -x 

# remove obsolete CentOS repos
cd /etc/yum.repos.d/
rm CentOS-Base.repo CentOS-SCLo-scl-rh.repo CentOS-SCLo-scl.repo CentOS-fasttrack.repo CentOS-x86_64-kernel.repo

yum install -y yum-plugin-ovl # fix for docker overlay fs
yum install -y xz

# determine arch
ARCH=$(uname -m)
if [[ $ARCH = *x86_64* ]]; then
        # container is 64-bit
        ARCH="x64"
elif [[ $ARCH = *i?86* ]]; then
        # container is 32-bit
        ARCH="x86"
fi


# download, compile, and install libaio as static library
cd ~
curl -L http://ftp.de.debian.org/debian/pool/main/liba/libaio/libaio_0.3.113.orig.tar.gz -o "libaio.tar.gz"
tar xf libaio.tar.gz
cd libaio-*/src
ENABLE_SHARED=0 make prefix=/hbb_exe install

# Activate Holy Build Box exe compilation environment
source /hbb_exe/activate

# download and compile fio
cd ~
curl -L https://github.com/axboe/fio/archive/fio-3.39.tar.gz -o "fio.tar.gz"
tar xf fio.tar.gz
cd fio-fio*
./configure --disable-native
make

# verify no external shared library links
libcheck fio
# copy fio binary to mounted dir
cp fio "/io/fio_$ARCH"

# download and compile iperf
cd ~
curl -L https://github.com/esnet/iperf/archive/3.18.tar.gz -o "iperf.tar.gz"
tar xf iperf.tar.gz
cd iperf*
./configure --disable-shared --disable-profiling
make

# verify no external shared library links
libcheck src/iperf3
# copy iperf binary to mounted dir
cp src/iperf3 "/io/iperf3_$ARCH"

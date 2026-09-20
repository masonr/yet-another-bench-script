#!/bin/bash
set -e

# Activate Holy Build Box lib compiliation environment
source /hbb/activate

set -x 

# remove obsolete CentOS repos
cd /etc/yum.repos.d/
rm -f CentOS-Base.repo CentOS-SCLo-scl-rh.repo CentOS-SCLo-scl.repo CentOS-fasttrack.repo CentOS-x86_64-kernel.repo

yum install -y yum-plugin-ovl # fix for docker overlay fs
yum install -y xz

# download musl cross compilation toolchain - mirrored as a release asset on the
# repo since musl.cc blocks GitHub Actions IP ranges (musl.cc fallback kept)
cd ~
curl -fL -4 --retry 5 --retry-delay 2 --connect-timeout 15 "https://github.com/masonr/yet-another-bench-script/releases/download/toolchains/${CROSS}-cross.tgz" -o "${CROSS}-cross.tgz" \
	|| curl -fL -4 --retry 5 --retry-delay 2 --connect-timeout 15 "https://musl.cc/${CROSS}-cross.tgz" -o "${CROSS}-cross.tgz"
tar xf "${CROSS}-cross.tgz"

# download, compile, and install libaio as static library
cd ~
curl -L http://ftp.de.debian.org/debian/pool/main/liba/libaio/libaio_0.3.113.orig.tar.gz -o "libaio.tar.gz"
tar xf libaio.tar.gz
cd libaio-*/src
CC=/root/${CROSS}-cross/bin/${CROSS}-gcc ENABLE_SHARED=0 make prefix=/hbb_exe install

# Activate Holy Build Box exe compilation environment
source /hbb_exe/activate

# download and compile fio
cd ~
curl -L https://github.com/axboe/fio/archive/fio-3.42.tar.gz -o "fio.tar.gz"
tar xf fio.tar.gz
cd fio-fio-*
# fio >= 3.42 includes both linux/prctl.h and sys/prctl.h in backend.c, which
# conflicts under musl; sys/prctl.h alone is sufficient
sed -i '/#include <linux\/prctl.h>/d' backend.c
CC=/root/${CROSS}-cross/bin/${CROSS}-gcc ./configure --disable-native --build-static
# link against libatomic for 32-bit/ARM targets that lack native 64-bit atomics
make EXTLIBS+=' -latomic'

# verify no external shared library links
libcheck fio
# copy fio binary to mounted dir
cp fio "/io/fio_$ARCH"

# download and compile iperf
cd ~
curl -L https://github.com/esnet/iperf/archive/3.21.tar.gz -o "iperf.tar.gz"
tar xf iperf.tar.gz
cd iperf-*
CC=/root/${CROSS}-cross/bin/${CROSS}-gcc ./configure --disable-shared --disable-profiling --build x86_64-pc-linux-gnu --host "${HOST}" --with-openssl=no --enable-static-bin
# remove libatomic.la so libtool links the static libatomic.a rather than
# attempting to link libatomic.so into the static binary (breaks arm32 builds)
rm -f "/root/${CROSS}-cross/${CROSS}/lib/libatomic.la"
make

# verify no external shared library links
libcheck src/iperf3
# copy iperf binary to mounted dir
cp src/iperf3 "/io/iperf3_$ARCH"

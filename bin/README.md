## YABS Static Binaries

This directory contains all of the static binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The static binaries were compiled on local Debian 7 VMs. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Static Binaries

* **fio_x64.static** - v3.17-66-gb7ed (compiled 13 Jan 2020) - 64-bit version
* **fio_x86.static** - v3.17-67-g7eff0 (compiled 13 Jan 2020) - 32-bit version
* **iperf_x64.static** - v3.7+ (compiled 13 Jan 2020) - 64-bit version
* **iperf_x86.static** - v3.7+ (compiled 13 Jan 2020) - 32-bit version

### Compile Notes

**Pre-reqs**:

```sh
apt install build-essential git libc6-dev libaio-dev zlib1g-dev libssl-dev
```

_(or equivalents in other package repos)_

**fio**:

```sh
git clone https://github.com/axboe/fio
cd fio
./configure --build-static
make
```

fio static binary will be in current dir

**iperf3**:

```sh
git clone https://github.com/esnet/iperf
cd iperf
./configure "LDFLAGS=--static" --disable-shared --disable-profiling
make
```

iperf3 static binary will be in the src dir

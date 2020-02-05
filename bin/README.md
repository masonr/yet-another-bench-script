## YABS Pre-Compiled Binaries

This directory contains all of the binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The static binaries were compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment in order to ensure the most portability. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Binaries

* **fio_x64** - v3.17 (compiled 28 Jan 2020) - 64-bit version
* **fio_x86** - v3.17 (compiled 28 Jan 2020) - 32-bit version
* **iperf_x64** - v3.7 (compiled 28 Jan 2020) - 64-bit version
* **iperf_x86** - v3.7 (compiled 28 Jan 2020) - 32-bit version

### Compile Notes

**Pre-reqs**:
  * Docker - https://www.docker.com/

**Compiling 64-bit binaries**:

```
docker run -t -i --rm -v `pwd`:/io phusion/holy-build-box-64:latest bash /io/compile.sh
```

**Compiling 32-bit binaries**:

```
docker run -t -i --rm -v `pwd`:/io phusion/holy-build-box-32:latest linux32 bash /io/compile.sh
```

64-bit and 32-bit binaries will be placed in the current directory.

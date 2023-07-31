## YABS Pre-Compiled Binaries

This directory contains all of the binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The binaries were compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment in order to ensure the most portability. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Binaries

| Binary Name | Version | Compile Date | Architecture | OS |
|:-:|:-:|:-:|:-:|:-:|
| fio_x64 | 3.35 | 12-JUL-2023 | x86_64 | 64-bit |
| fio_x86 | 3.35 |  12-JUL-2022 | x86 | 32-bit |
| fio_aarch64 | 3.35 | 12-JUL-2023 | ARM | 64-bit |
| fio_arm | 3.35 | 12-JUL-2023 | ARM | 32-bit |
| iperf_x64 | 3.14 | 12-JUL-2023 | x86_64 | 64-bit |
| iperf_x86 | 3.14 |  12-JUL-2023 | x86 | 32-bit |
| iperf_aarch64 | 3.14 | 12-JUL-2023 | ARM | 64-bit |
| iperf_arm | 3.14 | 12-JUL-2023 | ARM | 32-bit |

Note: ARM compatibility is considered experimental. Static binaries for 32-bit and ARM-based machines are cross-compiled within a Holy Build Box container using the [musl toolchain](https://musl.cc/).

### Compile Notes

**Pre-reqs**:
  * Docker - https://www.docker.com/

**Compiling 64-bit binaries**:

```sh
docker run -t -i --rm -v `pwd`:/io phusion/holy-build-box-64:latest bash /io/compile.sh
```

64-bit binaries will be placed in the current directory.

### Cross-compiling Notes

Compilation of ARM-compatible binaries requires additional environment variables to identify the proper musl toolchain and architecture to target for cross-compilation.

**Compiling 32-bit binaries**:

```sh
docker run -t -i --rm -v `pwd`:/io --env ARCH=i686 --env CROSS=i686-linux-musl --env HOST=i686-linux-musl phusion/holy-build-box-64:latest bash /io/cross-compile.sh
```

**Compiling ARM 64-bit binaries**:

```sh
docker run -t -i --rm -v `pwd`:/io --env ARCH=aarch64 --env CROSS=aarch64-linux-musl --env HOST=aarch64-linux-gnu phusion/holy-build-box-64:latest bash /io/cross-compile.sh
```

**Compiling ARM 32-bit binaries**:

```sh
docker run -t -i --rm -v `pwd`:/io --env ARCH=arm --env CROSS=arm-linux-musleabihf --env HOST=arm-linux-gnueabihf phusion/holy-build-box-64:latest bash /io/cross-compile.sh
```

64-bit (aarch64) and 32-bit (x86, arm) binaries will be placed in the current directory.

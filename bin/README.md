## YABS Pre-Compiled Binaries

This directory contains all of the binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The binaries were compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment in order to ensure the most portability. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Binaries

| Binary Name | Version | Compile Date | Architecture | OS | SHA-256 Hash<br>(VirusTotal Scan) |
|:-:|:-:|:-:|:-:|:-:|:-:|
| fio_x64 | 3.36 | 20-OCT-2023 | x86_64 | 64-bit | [5d345d0](https://www.virustotal.com/gui/file/5d345d0eac6da12753c5296d86393cec046d1a7e5794594aa62127a19001ce30) |
| fio_x86 | 3.36 |  20-OCT-2023 | i686 | 32-bit | [82aa945](https://www.virustotal.com/gui/file/82aa94592e3498c8a84e6563e070d61a40f7ac385a846c752e6f22f941c10d20) |
| fio_aarch64 | 3.36 | 20-OCT-2023 | ARM (aarch64) | 64-bit | [52d02cb](https://www.virustotal.com/gui/file/52d02cb20959ac488b2369a6fdaad421211619c309deb1d7a795279242a30b22) |
| fio_arm | 3.36 | 20-OCT-2023 | ARM  | 32-bit | [b84c3de](https://www.virustotal.com/gui/file/b84c3de74eec4073b7770569937ddbcaef3dc5c33c0e03401694ff277494e745) |
| iperf_x64 | 3.15 | 20-OCT-2023 | x86_64 | 64-bit | [d713ce4](https://www.virustotal.com/gui/file/d713ce4ecc83bfae34c822e7d725c9fdc3a32ea68633a25e11142202974c09a1) |
| iperf_x86 | 3.15 |  20-OCT-2023 | i686 | 32-bit | [dd3d22b](https://www.virustotal.com/gui/file/dd3d22b5b83a8af74b3af1f6bb492bef890e6ebd363ad2f1584780429e4bb24d) |
| iperf_aarch64 | 3.15 | 20-OCT-2023 | ARM (aarch64) | 64-bit | [d223f5f](https://www.virustotal.com/gui/file/d223f5fac4ce1c68b57ae9c12f038d593922a509786477ec18deb0bf52cce8bc) |
| iperf_arm | 3.15 | 20-OCT-2023 | ARM | 32-bit | [310e80f](https://www.virustotal.com/gui/file/310e80f442dda47fa0fe41225af85e8b91e75116dce5187f123380fd3c3c85a8) |

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
docker run -t -i --rm -v `pwd`:/io --env ARCH=x86 --env CROSS=i686-linux-musl --env HOST=i686-linux-musl phusion/holy-build-box-64:latest bash /io/cross-compile.sh
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

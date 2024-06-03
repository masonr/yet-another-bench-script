## YABS Pre-Compiled Binaries

This directory contains all of the binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The binaries were compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment in order to ensure the most portability. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Binaries

| Binary Name | Version | Compile Date | Architecture | OS | SHA-256 Hash<br>(VirusTotal Scan) |
|:-:|:-:|:-:|:-:|:-:|:-:|
| fio_x64 | 3.37 | 22-APR-2024 | x86_64 | 64-bit | [54e5552](https://www.virustotal.com/gui/file/54e5552f714e4583c8f81419e3a3b432f3730780531ac39dca43df5174df6e06) |
| fio_x86 | 3.37 |  22-APR-2024 | i686 | 32-bit | [dce3615](https://www.virustotal.com/gui/file/dce3615fe7ff360447b9148f533422b4ca64e67579735e412c844bc718cf7f8c) |
| fio_aarch64 | 3.37 | 22-APR-2024 | ARM (aarch64) | 64-bit | [3c1bf69](https://www.virustotal.com/gui/file/3c1bf6944d61cf0f900980b2eefca6e90919b6c8a79cedbd175fe9a2c3d9c285) |
| fio_arm | 3.37 | 22-APR-2024 | ARM  | 32-bit | [9917be5](https://www.virustotal.com/gui/file/9917be59238204bcaf1ccd5e08ab8e2a6bec6e5162ba8a4cf62ab8bb506ac9c1) |
| iperf_x64 | 3.17.1 | 02-JUN-2024 | x86_64 | 64-bit | [bd5f0b8](https://www.virustotal.com/gui/file/bd5f0b8f6961cb7d0cc3b306ecb3d1eb9e2ca6352ec0166d8bd31dfb050a78dd) |
| iperf_x86 | 3.17.1 |  02-JUN-2024 | i686 | 32-bit | [2708340](https://www.virustotal.com/gui/file/270834037817dcc5b54d1ed040464293dab350ef52bc5ae84788c57dbba5395c) |
| iperf_aarch64 | 3.17.1 | 02-JUN-2024 | ARM (aarch64) | 64-bit | [5b391dc](https://www.virustotal.com/gui/file/5b391dc8361d346a80b4589ebef21f0fc4751eac0328a6a71a5fbe2b5cc9e01a) |
| iperf_arm | 3.15* | 20-OCT-2023 | ARM | 32-bit | [310e80f](https://www.virustotal.com/gui/file/310e80f442dda47fa0fe41225af85e8b91e75116dce5187f123380fd3c3c85a8) |

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

**Compiling ARM 32-bit binaries\***:

```sh
docker run -t -i --rm -v `pwd`:/io --env ARCH=arm --env CROSS=arm-linux-musleabihf --env HOST=arm-linux-gnueabihf phusion/holy-build-box-64:latest bash /io/cross-compile.sh
```

64-bit (aarch64) and 32-bit (x86, arm) binaries will be placed in the current directory.

\* ARM 32-bit: Last sucessful compiliation of ARM 32-bit binary for iperf3 is v3.15. All later versions fail to compile.

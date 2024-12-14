## YABS Pre-Compiled Binaries

This directory contains all of the binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The binaries were compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment in order to ensure the most portability. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Binaries

| Binary Name | Version | Compile Date | Architecture | OS | SHA-256 Hash<br>(VirusTotal Scan) |
|:-:|:-:|:-:|:-:|:-:|:-:|
| fio_x64 | 3.38 | 14-DEC-2024 | x86_64 | 64-bit | [b802ea1](https://www.virustotal.com/gui/file/b802ea1460f8a0ab6a9d8a48d5d23dec8f68228293b88c2e4567424e6d2a7a47) |
| fio_x86 | 3.38 |  14-DEC-2024 | i686 | 32-bit | [8f06655](https://www.virustotal.com/gui/file/8f066550c35a8c6bbb53c80264ec0c1962128267562a785391fd3bb36ca489cb) |
| fio_aarch64 | 3.38 | 23-NOV-2024 | ARM (aarch64) | 64-bit | [ed703a8](https://www.virustotal.com/gui/file/ed703a87951992696a0870dfb3094956ebe0f5ea304918dc05a921d32aacb760) |
| fio_arm | 3.38 | 23-NOV-2024 | ARM  | 32-bit | [b52a809](https://www.virustotal.com/gui/file/b52a809f748587909c429edc14e54299249aedb19b5db72a60affc0de4b5c608) |
| iperf3_x64 | 3.18 | 14-DEC-2024 | x86_64 | 64-bit | [ef787ab](https://www.virustotal.com/gui/file/ef787abbe4b09c7958ed592df52dfe3a2848cbdee5b76738c757d7c51c348053) |
| iperf3_x86 | 3.18 |  14-DEC-2024 | i686 | 32-bit | [655eb51](https://www.virustotal.com/gui/file/655eb51abc36ddaa624c1d0e98c6930e8b1e9d91c85e5a3443624355656be9b9) |
| iperf3_aarch64 | 3.18 | 14-DEC-2024 | ARM (aarch64) | 64-bit | [92e5821](https://www.virustotal.com/gui/file/92e5821cfbaa1f8faf123b4d6773dc0f6efef221b9308668a21ddabc04a1de20) |
| iperf3_arm | 3.15* | 20-OCT-2023 | ARM | 32-bit | [310e80f](https://www.virustotal.com/gui/file/310e80f442dda47fa0fe41225af85e8b91e75116dce5187f123380fd3c3c85a8) |

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

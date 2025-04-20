## YABS Pre-Compiled Binaries

This directory contains all of the binaries required to run the benchmarking tests. Naturally, there is a security risk to your machine and its contents by running this script since, after all, this is just a script on the internet. You'll simply have to have confidence that I don't have malicious intent and am semi-competent at writing a bash script. The script is made public so you can look at the code yourself. The binaries were compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment in order to ensure the most portability. The compiled binary version numbers and compilations steps are noted below. Please open an issue if the compiled version is out of date and lacking any security-related and/or performance updates.

### Binaries

| Binary Name | Version | Compile Date | Architecture | OS | SHA-256 Hash<br>(VirusTotal Scan) |
|:-:|:-:|:-:|:-:|:-:|:-:|
| fio_x64 | 3.39 | 20-APR-2025 | x86_64 | 64-bit | [b511bda](https://www.virustotal.com/gui/file/b511bda3b26b6d840698f543d63e956d7466b8512c10ff0ada8292d556c33fb1) |
| fio_x86 | 3.39 | 20-APR-2025 | i686 | 32-bit | [42e2e0b](https://www.virustotal.com/gui/file/42e2e0b0370faeb8e53dcf48dfff15daa9baaadfd196d9bdda57af196bedf0b3) |
| fio_aarch64 | 3.39 | 20-APR-2025 | ARM (aarch64) | 64-bit | [e2942a2](https://www.virustotal.com/gui/file/e2942a26d4b249076486677c9c12cd7f1a572854a5e136597d1391e8ad75ffb0) |
| fio_arm | 3.39 | 20-APR-2025 | ARM  | 32-bit | [3a96b1c](https://www.virustotal.com/gui/file/3a96b1cadfb51501b7fd54dc47a4dad666dc4382d4fe152116c62ae6a07485ea) |
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

## YABS Pre-Compiled Binaries

This directory contains the compilation scripts used to build the fio and iperf3
binaries that YABS uses. **The binaries themselves are no longer committed to the
repository** - they are built automatically by GitHub Actions workflows
([build-fio.yml](../.github/workflows/build-fio.yml) and
[build-iperf3.yml](../.github/workflows/build-iperf3.yml)) on GitHub-hosted
runners and published as release assets on this repository:

* `fio-*` releases (e.g. `fio-3.42`) - contain `fio_x64`, `fio_x86`, `fio_aarch64`, `fio_arm`
* `iperf3-*` releases (e.g. `iperf3-3.21`) - contain `iperf3_x64`, `iperf3_x86`, `iperf3_aarch64`, `iperf3_arm`
* `toolchains` release - musl cross-compilation toolchains mirrored from
  [musl.cc](https://musl.cc/) (which blocks GitHub Actions IP ranges); see the
  NOTICE.txt asset for licensing/source info

Each binary release includes SHA-256 checksums (`*-checksums.sha256`), a
VirusTotal scan summary in the release notes, and the exact upstream source
tarball the binaries were built from. Binaries are cross-compiled with musl
toolchains for maximum portability.

At runtime, yabs.sh auto-detects the latest `fio-*`/`iperf3-*` release via the
repository's releases feed and downloads the appropriate binary for the host
architecture. If the lookup fails, it falls back to a pinned release tag.

Naturally, there is a security risk to your machine and its contents by running
this script since, after all, this is just a script on the internet. You'll
simply have to have confidence that I don't have malicious intent and am
semi-competent at writing a bash script. The script and the workflows that build
the binaries are public so you can look at the code yourself. The binaries are
compiled using a [Holy Build Box](https://github.com/phusion/holy-build-box)
compilation environment in order to ensure the most portability. Please open an
issue if the binaries are out of date and lacking any security-related and/or
performance updates - the daily scheduled workflows should pick up new upstream
releases automatically.

Note: ARM compatibility is considered experimental.

### Compile Notes (manual builds)

The workflows above are the canonical build path. To build manually, the same
scripts can be run inside a Holy Build Box container:

**Pre-reqs**:
  * Docker - https://www.docker.com/

**Compiling 64-bit (x86_64) binaries**:

```sh
docker run -t -i --rm -v `pwd`:/io phusion/holy-build-box-64:latest bash /io/compile.sh
```

64-bit binaries will be placed in the current directory.

### Cross-compiling Notes

Compilation of 32-bit and ARM-compatible binaries requires additional
environment variables to identify the proper musl toolchain and architecture to
target for cross-compilation.

**Compiling 32-bit x86 binaries**:

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

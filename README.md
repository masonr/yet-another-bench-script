# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl -sL yabs.sh | bash`

This script has been tested on CentOS 7, CentOS 8, Debian 9, Debian 10, Fedora 30, Ubuntu 16.04, and Ubuntu 18.04. It is designed to not require any external dependencies to be installed nor elevated privileges to run.

**IPv6-Only Machines**: The above command will not work on IPv6-only machines. [See below](#ipv6-only-machines)


### Skipping Tests

By default, the script runs all three tests described in the next section below. In the event that you wish to skip one or more of the tests, use the commands below:

```
curl -sL yabs.sh | bash -s -- -{fig}
```

* `-f`/`-d` this option disables the fio (disk performance) test
* `-i` this option disables the iperf (network performance) test
* `-g` this option disables the Geekbench (system performance) test

Options can be grouped together to skip multiple tests, i.e. `-fg` to skip the disk and system performance tests (effectively only testing network performance).

## Tests Conducted

* **fio** - the most comprehensive I/O testing software available, fio grants the ability to evaluate disk performance in a variety of methods with a variety of options. Four random read and write fio disk tests are conducted as part of this script with 4k, 64k, 512k, and 1m block sizes. The tests are designed to evaluate disk throughput in near-real world (using random) scenarios with a 50/50 split (50% reads and 50% writes per test).
* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.
* **Geekbench 4** - Geekbench is a benchmarking program that measures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and allow comparison to other geekbench'd systems. The claim URL to add the Geekbench 4 result to your Geekbench profile is written to a file in the directory that this script is executed from.

### Security Notice

This script relies on external binaries in order to complete the performance tests. The network (iperf3) and disk (fio) tests use binaries that are compiled by myself utilizing a [Holy Build Box](https://github.com/phusion/holy-build-box) compiliation environment to ensure binary portability. The reasons for doing this include ensuring standardized (parsable) output, allowing support of both 32-bit and 64-bit architectures, bypassing the need for prerequisites to be compiled and/or installed, among other reasons. For the system test, a Geekbench 4 tarball is downloaded, extracted, and the resulting binary is run. Use this script at your own risk as you would with any script publicly available on the net. Additional information regarding the binaries, including compilation notes and steps, can be found in the bin directory's [README page](bin/README.md).

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2020-02-04                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Tue Feb  4 19:04:24 UTC 2020

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E3-1270 v6 @ 3.80GHz
CPU cores  : 8 @ 800.098 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ✔ Enabled
RAM        : 31G
Swap       : 0B
Disk       : 221G

fio Disk Speed Tests (Mixed R/W 50/50):
---------------------------------
Block Size | 4kb           (IOPS) | 64kb          (IOPS)
  ------   | ---            ----  | ----           ----
Read       | 69.37 MB/s   (17.3k) | 106.51 MB/s   (1.6k)
Write      | 69.57 MB/s   (17.3k) | 107.07 MB/s   (1.6k)
Total      | 138.94 MB/s  (34.7k) | 213.59 MB/s   (3.3k)
           |                      |
Block Size | 512kb         (IOPS) | 1mb           (IOPS)
  ------   | -----          ----  | ---            ----
Read       | 133.52 MB/s    (260) | 141.90 MB/s    (138)
Write      | 140.61 MB/s    (274) | 151.35 MB/s    (147)
Total      | 274.13 MB/s    (534) | 293.26 MB/s    (285)

iperf3 Network Speed Tests (IPv4):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 1.41 Gbits/sec  | 1.13 Gbits/sec
Online.net                | Paris, FR (10G)           | 1.44 Gbits/sec  | 1.29 Gbits/sec
Worldstream               | The Netherlands (10G)     | 1.18 Gbits/sec  | 1.22 Gbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 805 Mbits/sec   | 1.13 Gbits/sec
Biznet                    | Bogor, Indonesia (1G)     | 768 Mbits/sec   | 38.5 Mbits/sec
Hostkey                   | Moscow, RU (1G)           | 503 Mbits/sec   | 686 Mbits/sec
Velocity Online           | Tallahassee, FL, US (10G) | 2.74 Gbits/sec  | 2.67 Gbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 3.36 Gbits/sec  | 963 Mbits/sec
Hurricane Electric        | Fremont, CA, US (10G)     | 6.34 Gbits/sec  | 3.76 Gbits/sec

iperf3 Network Speed Tests (IPv6):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 1.44 Gbits/sec  | 1.25 Gbits/sec
Online.net                | Paris, FR (10G)           | 1.36 Gbits/sec  | 972 Mbits/sec
Worldstream               | The Netherlands (10G)     | 1.19 Gbits/sec  | 1.20 Gbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 826 Mbits/sec   | 1.14 Gbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | busy            | busy
Hurricane Electric        | Fremont, CA, US (10G)     | 6.36 Gbits/sec  | 2.95 Gbits/sec

Geekbench 4 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 5587
Multi Core      | 19093
Full Test       | https://browser.geekbench.com/v4/cpu/15200550

```

## IPv6 Only Machines

GitHub's CDN does not resolve via IPv6. You will need to run the following command to download and run the script.

`curl -s -k -g --header 'Host: raw.githubusercontent.com' https://[2a04:4e42::133]/masonr/yet-another-bench-script/master/yabs.sh | bash`

(2a04:4e42::133 is fastly.net's [GitHub's CDN Provider] IPv6 address)

## Acknoledgements

This script was inspired by several great benchmarking scripts out there, including, but not limited to, [bench.sh](https://bench.sh/), [nench.sh](https://github.com/n-st/nench), [ServerBench](https://github.com/K4Y5/ServerBench), among others. Members of both the [HostedTalk](https://hostedtalk.net), [LowEndSpirit](https://talk.lowendspirit.com), and [LowEndTalk](https://www.lowendtalk.com) hosting-related communities play a pivotal role in testing, evaluating, and shaping this script as it matures.

## License
```
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2019 Mason Rowe <mason@rowe.sh>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```

# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://user-images.githubusercontent.com/8313125/106475387-e1f6da00-6473-11eb-918c-c785ebeef8b9.jpg)
Logo design by [Dian Pratama](https://github.com/dianp)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

View YABS usage stats [here](https://yabs.rowe.sh).

## How to Run

`curl -sL yabs.sh | bash` 

or 

`wget -qO- yabs.sh | bash`

This script has been tested on the following Linux distributions: CentOS 6+, Debian 8+, Fedora 30, and Ubuntu 16.04+. It is designed to not require any external dependencies to be installed nor elevated privileges to run.

**Local fio/iperf3 Packages**: If the tested system has fio and/or iperf3 already installed, the local package will take precedence over the precompiled binary.

**Experimental ARM Compatibility**: Initial ARM compatibilty has been introduced, however, is not considered entirely stable due to limited testing on distinct ARM devices. Report any errors or issues.

**High Bandwidth Usage Notice**: By default, this script will perform many iperf network tests, which will try to max out the network port for ~20s per location (10s in each direction). Low-bandwidth servers (such as a NAT VPS) should consider running this script with the `-r` flag (for reduced iperf locations) or the `-i` flag (to disable network tests entirely).

### Flags (Skipping Tests, Reducing iperf Locations, Geekbench 4, etc.)

By default, the script runs all three tests described in the next section below. In the event that you wish to skip one or more of the tests, use the commands below:

```
curl -sL yabs.sh | bash -s -- -{bfdighr49}
```

* `-b` this option forces use of pre-compiled binaries from repo over local packages
* `-f`/`-d` this option disables the fio (disk performance) test
* `-i` this option disables the iperf (network performance) test
* `-g` this option disables the Geekbench (system performance) test
* `-h` this option prints the help message with usage, flags detected, and local package (fio/iperf) status
* `-r` this option reduces the number of iperf locations (Online.net/Clouvider LON+NYC) to lessen bandwidth usage
* `-4` this option overrides the Geekbench 5 performance test and runs a Geekbench 4 test instead
* `-9` this option runs the Geekbench 4 test in addition to the Geekbench 5 test

Options can be grouped together to skip multiple tests, i.e. `-fg` to skip the disk and system performance tests (effectively only testing network performance).

**Geekbench License Key**: A Geekbench license key can be utilized during the Geekbench test to unlock all features. Simply put the email and key for the license in a file called _geekbench.license_. `echo "email@domain.com ABCDE-12345-FGHIJ-57890" > geekbench.license`

## Tests Conducted

* **[fio](https://github.com/axboe/fio)** - the most comprehensive I/O testing software available, fio grants the ability to evaluate disk performance in a variety of methods with a variety of options. Four random read and write fio disk tests are conducted as part of this script with 4k, 64k, 512k, and 1m block sizes. The tests are designed to evaluate disk throughput in near-real world (using random) scenarios with a 50/50 split (50% reads and 50% writes per test).
* **[iperf3](https://github.com/esnet/iperf)** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 5 tries, the speed test for that location/direction is skipped.
* **[Geekbench](https://www.geekbench.com/)** - Geekbench is a benchmarking program that measures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and allow comparison to other geekbench'd systems. The claim URL to add the Geekbench result to your Geekbench profile is written to a file in the directory that this script is executed from. By default, Geekbench 5 is the only Geekbench test performed, however, Geekbench 4 can also be toggled on by passing the appropriate flag.

### Security Notice

This script relies on external binaries in order to complete the performance tests. The network (iperf3) and disk (fio) tests use binaries that are compiled by myself utilizing a [Holy Build Box](https://github.com/phusion/holy-build-box) compiliation environment to ensure binary portability. The reasons for doing this include ensuring standardized (parsable) output, allowing support of both 32-bit and 64-bit architectures, bypassing the need for prerequisites to be compiled and/or installed, among other reasons. For the system test, a Geekbench tarball is downloaded, extracted, and the resulting binary is run. Use this script at your own risk as you would with any script publicly available on the net. Additional information regarding the binaries, including compilation notes and steps, can be found in the bin directory's [README page](bin/README.md).

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2020-09-21                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Mon 21 Sep 2020 12:31:13 AM EDT

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
CPU cores  : 12 @ 800.087 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ✔ Enabled
RAM        : 15Gi
Swap       : 14Gi
Disk       : 865G

fio Disk Speed Tests (Mixed R/W 50/50):
---------------------------------
Block Size | 4k            (IOPS) | 64k           (IOPS)
  ------   | ---            ----  | ----           ----
Read       | 445.04 MB/s (111.2k) | 475.05 MB/s   (7.4k)
Write      | 446.22 MB/s (111.5k) | 477.55 MB/s   (7.4k)
Total      | 891.26 MB/s (222.8k) | 952.60 MB/s  (14.8k)
           |                      |
Block Size | 512k          (IOPS) | 1m            (IOPS)
  ------   | ---            ----  | ----           ----
Read       | 474.42 MB/s    (926) | 472.32 MB/s    (461)
Write      | 499.63 MB/s    (975) | 503.77 MB/s    (491)
Total      | 974.05 MB/s   (1.9k) | 976.10 MB/s    (952)

iperf3 Network Speed Tests (IPv4):
---------------------------------
Provider        | Location (Link)           | Send Speed      | Recv Speed
                |                           |                 |
Clouvider       | London, UK (10G)          | 1.19 Gbits/sec  | 2.39 Gbits/sec
Online.net      | Paris, FR (10G)           | 2.35 Gbits/sec  | 2.04 Gbits/sec
WorldStream     | The Netherlands (10G)     | 2.17 Gbits/sec  | 1.29 Gbits/sec
Wifx            | Zurich, CH (10G)          | 1.28 Gbits/sec  | 522 Mbits/sec
Biznet          | Jakarta, Indonesia (1G)   | 19.4 Mbits/sec  | 41.8 Mbits/sec
Clouvider       | NYC, NY, US (10G)         | 9.40 Gbits/sec  | 9.41 Gbits/sec
Velocity Online | Tallahassee, FL, US (10G) | 2.39 Gbits/sec  | 2.94 Gbits/sec
Clouvider       | Los Angeles, CA, US (10G) | 2.40 Gbits/sec  | 2.89 Gbits/sec
Iveloz Telecom  | Sao Paulo, BR (2G)        | 136 Mbits/sec   | 192 Mbits/sec

iperf3 Network Speed Tests (IPv6):
---------------------------------
Provider        | Location (Link)           | Send Speed      | Recv Speed
                |                           |                 |
Clouvider       | London, UK (10G)          | 803 Mbits/sec   | 2.09 Gbits/sec
Online.net      | Paris, FR (10G)           | 2.32 Gbits/sec  | 2.20 Gbits/sec
WorldStream     | The Netherlands (10G)     | 1.95 Gbits/sec  | 1.49 Gbits/sec
Wifx            | Zurich, CH (10G)          | 168 Mbits/sec   | 579 Mbits/sec
Clouvider       | NYC, NY, US (10G)         | 9.28 Gbits/sec  | 9.28 Gbits/sec
Clouvider       | Los Angeles, CA, US (10G) | 2.80 Gbits/sec  | 2.90 Gbits/sec

Geekbench 4 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 6035
Multi Core      | 24473
Full Test       | https://browser.geekbench.com/v4/cpu/15770150

Geekbench 5 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 1348
Multi Core      | 5857
Full Test       | https://browser.geekbench.com/v5/cpu/3844555

```

## Acknowledgements

This script was inspired by several great benchmarking scripts out there, including, but not limited to, [bench.sh](https://bench.sh/), [nench.sh](https://github.com/n-st/nench), [ServerBench](https://github.com/K4Y5/ServerBench), among others. Members of the [HostedTalk](https://hostedtalk.net), [LowEndSpirit](https://talk.lowendspirit.com), and [LowEndTalk](https://www.lowendtalk.com) hosting-related communities play a pivotal role in testing, evaluating, and shaping this script as it matures.

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

# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh | bash`

This script has been tested on CentOS 7, CentOS 8, Debian 9, Debian 10, Fedora 30, Ubuntu 16.04, and Ubuntu 18.04. It is designed to not require any external dependencies to be installed nor elevated privileges.

### Skipping Tests

By default, the script runs all three tests described in the next section below. In the event that you wish to skip one or more of the tests, use the commands below:

```
curl https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh -o yabs.sh; chmod +x yabs.sh
./yabs.sh -{dig}
```

* `-d` this option disables the dd (disk performance) test
* `-i` this option disables the iperf (network performance) test
* `-g` this option disables the Geekbench (system performance) test

Options can be grouped together to skip multiple tests, i.e. `./yabs -dg` to skip the disk and system performance tests (effectively only testing network performance).

## Tests Conducted

* **dd** - the dd utility is utilized to test sequential write and read disk performance.
* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.
* **Geekbench 4** - Geekbench is a benchmarking program that measures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and allow comparison to other geekbench'd systems. The claim URL to add the Geekbench 4 result to your Geekbench profile is written to a file in the directory that this script is executed from.

### Note on Disk Performance Test

This script uses dd's sequential throughput test in order to test both write and read speeds to the disk. It is well known that sequential disk speeds are not necessarily indicative of actual, real-world performance. A superior method to testing disk performance using real-world scenarios is [fio (Flexible I/O Tester)](https://github.com/axboe/fio). Fio was not utilized within this script because the program needs to be compiled and installed on the user's system to run correctly, thus clashes with YABS' tenet to not require any dependencies (installed or compiled) or admin rights to run the script. The sequential dd tests are merely provided as a convienence for the end user.

### Security Notice

This script relies on two external binaries in order to complete the network and system performance tests. For the network test, an iperf3 binary and shared library are downloaded from the official source at iperf.fr. For the system test, a Geekbench 4 tarball is downloaded, extracted, and the resulting binary is run. The security risks of running these binaries are minimal, however, use this script at your own risk as you would with any script publicly available on the net.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2020-01-08                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Wed 08 Jan 2020 07:33:21 PM UTC

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E3-1270 v6 @ 3.80GHz
CPU cores  : 8 @ 4098.759 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ✔ Enabled
RAM        : 31Gi
Swap       : 0B
Disk       : 221G

dd Sequential Disk Speed Tests:
---------------------------------
       | Test 1      | Test 2      | Test 3      | Avg
       |             |             |             |
Write  | 291 MB/s    | 286 MB/s    | 281 MB/s    | 286.00 MB/s
Read   | 179 MB/s    | 188 MB/s    | 179 MB/s    | 182.00 MB/s

iperf3 Network Speed Tests (IPv4):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 2.93 Gbits/sec  | 7.80 Gbits/sec
Online.net                | Paris, FR (10G)           | 7.79 Gbits/sec  | 5.20 Gbits/sec
Severius                  | The Netherlands (10G)     | 8.98 Gbits/sec  | 2.53 Gbits/sec
Worldstream               | The Netherlands (10G)     | 8.65 Gbits/sec  | 8.57 Gbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 7.80 Gbits/sec  | 9.03 Gbits/sec
Biznet                    | Bogor, Indonesia (1G)     | 752 Mbits/sec   | busy
Hostkey                   | Moscow, RU (1G)           | 905 Mbits/sec   | 449 Mbits/sec
Vultr                     | Piscataway, NJ, US (1G)   | 448 Mbits/sec   | 51.6 Mbits/sec
Velocity Online           | Tallahassee, FL, US (10G) | 1.74 Gbits/sec  | 1.61 Gbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 1.61 Gbits/sec  | 106 Mbits/sec
Hurricane Electric        | Fremont, CA, US (10G)     | 28.2 Mbits/sec  | 476 Mbits/sec

iperf3 Network Speed Tests (IPv6):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 7.78 Gbits/sec  | 6.00 Gbits/sec
Online.net                | Paris, FR (10G)           | 2.86 Gbits/sec  | 5.74 Gbits/sec
Severius                  | The Netherlands (10G)     | 6.96 Gbits/sec  | 2.38 Gbits/sec
Worldstream               | The Netherlands (10G)     | 7.29 Gbits/sec  | 6.02 Gbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 4.64 Gbits/sec  | 8.93 Gbits/sec
Vultr                     | Piscataway, NJ, US (1G)   | 97.5 Mbit/sec   | 37.3 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | busy            | busy
Hurricane Electric        | Fremont, CA, US (10G)     | 348 Mbits/sec   | 505 Mbits/sec

Geekbench 4 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 5714
Multi Core      | 19758
Full Test       | https://browser.geekbench.com/v4/cpu/15115430

```

## Acknoledgements

This script was inspired by several great benchmarking scripts out there, including, but not limited to, [bench.sh](https://bench.sh/), [nench.sh](https://github.com/n-st/nench), [ServerBench](https://github.com/K4Y5/ServerBench), among others. Members of both the [HostBalls](https://hostballs.com) and [LowEndTalk](https://www.lowendtalk.com) hosting-related communities play a pivotal role in testing, evaluating, and shaping this script as it matures.

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

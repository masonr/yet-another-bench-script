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

* `-d` this option disables the dd/ioping (disk performance) test
* `-i` this option disables the iperf (network performance) test
* `-g` this option disables the Geekbench (system performance) test

Options can be grouped together to skip multiple tests, i.e. `./yabs -dg` to skip the disk and system performance tests (effectively only testing network performance).

## Tests Conducted

* **dd** & **ioping** - the dd utility is utilized to test sequential write disk performance and the ioping utility is used to test sequential read disk performance.
* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.
* **Geekbench 4** - Geekbench is a benchmarking program that measures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and allow comparison to other geekbench'd systems. The claim URL to add the Geekbench 4 result to your Geekbench profile is written to a file in the directory that this script is executed from.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2019-10-08                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Tue Oct  8 12:27:29 EDT 2019

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
CPU cores  : 8 @ 1600.270 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ✔ Enabled
RAM        : 31G
Swap       : 7.5G
Disk       : 213G

Disk Speed Tests:
---------------------------------
       | Test 1      | Test 2      | Test 3      | Avg
       |             |             |             |
Write  | 363.00 MB/s | 361.00 MB/s | 354.00 MB/s | 359.33 MB/s
Read   | 411.58 MB/s | 399.94 MB/s | 398.18 MB/s | 403.23 MB/s

iperf3 Network Speed Tests (IPv4):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 348 Mbits/sec   | 223 Mbits/sec
Online.net                | Paris, FR (10G)           | 770 Mbits/sec   | 142 Mbits/sec
Severius                  | The Netherlands (10G)     | 687 Mbits/sec   | 106 Mbits/sec
Worldstream               | The Netherlands (10G)     | 739 Mbits/sec   | 86.1 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 775 Mbits/sec   | 85.0 Mbits/sec
Biznet                    | Bogor, Indonesia (1G)     | busy            | busy
Hostkey                   | Moscow, RU (1G)           | 639 Mbits/sec   | 438 Mbits/sec
Velocity Online           | Tallahassee, FL, US (10G) | 852 Mbits/sec   | 312 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 806 Mbits/sec   | 114 Mbits/sec
Hurricane Electric        | Fremont, CA, US (10G)     | 728 Mbits/sec   | busy

iperf3 Network Speed Tests (IPv6):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 724 Mbits/sec   | 241 Mbits/sec
Online.net                | Paris, FR (10G)           | 608 Mbits/sec   | 93.6 Mbits/sec
Severius                  | The Netherlands (10G)     | 291 Mbits/sec   | 103 Mbits/sec
Worldstream               | The Netherlands (10G)     | 699 Mbits/sec   | 80.4 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 630 Mbits/sec   | 77.3 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 783 Mbits/sec   | 190 Mbits/sec
Hurricane Electric        | Fremont, CA, US (10G)     | busy            | busy

Geekbench 4 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 4015
Multi Core      | 13157
Full Test       | https://browser.geekbench.com/v4/cpu/14775012

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

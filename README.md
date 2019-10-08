# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh | bash`

This script has been tested on CentOS 7, Debian 9, Debian 10, Fedora 30, Ubuntu 16.04, and Ubuntu 18.04. It is designed to not require any external dependencies to be installed nor elevated privileges.

### Skipping Tests

By default, the script runs all three tests described in the next section below. In the event that you wish to skip one or more of the tests, use the commands below:

```
curl https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh -o yabs.sh; chmod +x yabs.sh
./yabs.sh -{dig}
```

* `-d` this option disables the dd (disk performance) test
* `-i` this option disables the iperf (network performance) test
* `-g` this option disables the Geekbench (system performance) test

Options can be grouped together to skip multiple tests, i.e. `./yabs -dg` to skip the dd and Geekbench tests (effectively only performing the iperf test).

## Tests Conducted

* **dd** - the dd utility is utilized to test disk performance. Both write and read speeds are evaluated by writing to and reading from a test file. __\*Disclaimer__: read speeds may be heavily influenced by cache depending on configuration of the host.
* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.
* **Geekbench 4** - Geekbench is a benchmarking program that measures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and allow comparison to other geekbench'd systems. The claim URL to add the Geekbench 4 result to your Geekbench profile is written to a file in the directory that this script is executed from.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2019-10-06                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Sun Oct  6 22:03:26 EDT 2019

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
CPU cores  : 8 @ 1600.091 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ❌ Disabled
RAM        : 31G
Swap       : 7.5G
Disk       : 213G

dd Disk Speed Tests:
---------------------------------
       | Test 1     | Test 2     | Test 3     | Avg
       |            |            |            |
Write  | 361 MB/s   | 357 MB/s   | 357 MB/s   | 358.333 MB/s
Read*  | 409 MB/s   | 409 MB/s   | 410 MB/s   | 409.333 MB/s

iperf3 Network Speed Tests (IPv4):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 766 Mbits/sec   | 195 Mbits/sec
Online.net                | Paris, FR (10G)           | 771 Mbits/sec   | 156 Mbits/sec
Severius                  | The Netherlands (10G)     | 638 Mbits/sec   | 45.5 Mbits/sec
Worldstream               | The Netherlands (10G)     | 748 Mbits/sec   | 56.7 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 756 Mbits/sec   | 69.1 Mbits/sec
Biznet                    | Bogor, Indonesia (1G)     | busy            | busy
Hostkey                   | Moscow, RU (1G)           | 722 Mbits/sec   | 489 Mbits/sec
Velocity Online           | Tallahassee, FL, US (1G)  | 528 Mbits/sec   | 374 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 825 Mbits/sec   | 156 Mbits/sec
Hurricane Electric        | Fremont, CA, US (1G)      | 782 Mbits/sec   | busy

iperf3 Network Speed Tests (IPv6):
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 463 Mbits/sec   | 186 Mbits/sec
Online.net                | Paris, FR (10G)           | 713 Mbits/sec   | 75.7 Mbits/sec
Severius                  | The Netherlands (10G)     | 753 Mbits/sec   | 73.5 Mbits/sec
Worldstream               | The Netherlands (10G)     | 740 Mbits/sec   | 58.6 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 744 Mbits/sec   | 75.0 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 473 Mbits/sec   | 149 Mbits/sec
Hurricane Electric        | Fremont, CA, US (1G)      | busy            | busy

Geekbench 4 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 4012
Multi Core      | 13007
Full Test       | https://browser.geekbench.com/v4/cpu/14768101

```

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

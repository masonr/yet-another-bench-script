# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh | bash`

## Tests Conducted

* **dd** - the dd utility is utilized to test disk performance. Both write and read speeds are evaluated by writing to and reading from a test file. **\***Disclaimer: read speeds may be heavily influenced by cache depending on configuration of the host.
* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.
* **Geekbench 4** - Geekbench is a benchmarking program that meastures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and be compare to other geekbench'd systems. The claim URL to add the Geekbench 4 result to your Geekbench profile is written to a file in the directory that this script is executed from.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2019-10-05                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Sat Oct  5 21:44:13 EDT 2019

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz
CPU cores  : 32 @ 1200.563 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ❌ Disabled
RAM        : 62G
Swap       : 59G
Disk       : 44T

dd Disk Speed Tests:
---------------------------------
       | Test 1     | Test 2     | Test 3     | Avg
       |            |            |            |
Write  | 275 MB/s   | 177 MB/s   | 177 MB/s   | 209 MB/s
Read*  | 537 MB/s   | 539 MB/s   | 536 MB/s   | 537 MB/s

iperf3 Network Speed Tests:
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 160 Mbits/sec   | 158 Mbits/sec
Online.net                | Paris, FR (10G)           | 165 Mbits/sec   | 94.2 Mbits/sec
Severius                  | The Netherlands (10G)     | 161 Mbits/sec   | 151 Mbits/sec
Worldstream               | The Netherlands (10G)     | 166 Mbits/sec   | 88.1 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 160 Mbits/sec   | 148 Mbits/sec
Biznet                    | Bogor, Indonesia (1G)     | 118 Mbits/sec   | 57.5 Mbits/sec
Hostkey                   | Moscow, RU (1G)           | 148 Mbits/sec   | 135 Mbits/sec
Velocity Online           | Tallahassee, FL, US (1G)  | 179 Mbits/sec   | 133 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 186 Mbits/sec   | 150 Mbits/sec
Hurricane Electric        | Fremont, CA, US (1G)      | 168 Mbits/sec   | busy

Geekbench 4 CPU Performance Test:
---------------------------------
Test            | Value
                |
Single Core     | 3207
Multi Core      | 37289
Full Test       | https://browser.geekbench.com/v4/cpu/14763522

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

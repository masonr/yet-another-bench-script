# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh | bash`

## Tests Conducted

* **dd** - the dd utility is utilized to test disk performance. Both write and read speeds are evaluated by writing to and reading from a test file. Disclaimer: read speeds may be heavily influenced by cache depending on configuration of the host.
* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2019-10-04                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Fri Oct  4 21:06:05 EDT 2019

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
CPU cores  : 8 @ 2096.045 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ❌ Disabled
RAM        : 31G
Swap       : 7.5G
Disk       : 213G

dd Disk Speed Tests:
---------------------------------
       | Test 1     | Test 2     | Test 3     | Avg
       |            |            |            |
Write  | 361 MB/s   | 363 MB/s   | 362 MB/s   | 362 MB/s
Read   | 407 MB/s   | 410 MB/s   | 412 MB/s   | 409 MB/s

iperf3 Network Speed Tests:
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 759 Mbits/sec   | 282 Mbits/sec
Online.net                | Paris, FR (10G)           | 744 Mbits/sec   | 166 Mbits/sec
Severius                  | The Netherlands (10G)     | 782 Mbits/sec   | 111 Mbits/sec
Worldstream               | The Netherlands (10G)     | busy            | 75.7 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 807 Mbits/sec   | 56.7 Mbits/sec
Biznet                    | Bogor, Indonesia (1G)     | busy            | busy
Hostkey                   | Moscow, RU (1G)           | 191 Mbits/sec   | 474 Mbits/sec
Velocity Online           | Tallahassee, FL, US (?G)  | 860 Mbits/sec   | 452 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 312 Mbits/sec   | 234 Mbits/sec
Hurricane Electric        | Fremont, CA, US (1G)      | 794 Mbits/sec   | busy

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

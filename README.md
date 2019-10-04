# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl -s https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh | bash`

## Tests Conducted

* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2019-10-03                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Thu 03 Oct 2019 10:25:48 PM EDT

Basic System Information:
---------------------------------
Processor  : Intel(R) Xeon(R) CPU E5-1650 v3 @ 3.50GHz
CPU cores  : 4 @ 3499.996 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ❌ Disabled
RAM        : 3.9Gi
Swap       : 511Mi
Disk       : 66G

iperf3 Speed Tests:
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | 65.3 Mbits/sec  | 179 Mbits/sec
Online.net                | Paris, FR (10G)           | 892 Mbits/sec   | 553 Mbits/sec
Severius                  | The Netherlands (10G)     | 80.0 Mbits/sec  | 133 Mbits/sec
Worldstream               | The Netherlands (10G)     | 77.9 Mbits/sec  | 122 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | 79.7 Mbits/sec  | 126 Mbits/sec
Biznet                    | Bogor, Indonesia (1G)     | 0.00 bits/sec   | 0.00 bits/sec
Hostkey                   | Moscow, RU (1G)           | 864 Mbits/sec   | 882 Mbits/sec
Velocity Online           | Tallahassee, FL, US (?G)  | 90.4 Mbits/sec  | 211 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 57.8 Mbits/sec  | 127 Mbits/sec
Hurricane Electric        | Fremont, CA, US (1G)      | 4.89 Mbits/sec  | 102 Mbits/sec
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

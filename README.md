# Yet-Another-Bench-Script

Here's an attempt to create _yet another_ damn Linux server *bench*marking _script_.

![](https://imgs.xkcd.com/comics/standards.png)

This script isn't an attempt to be a golden standard. It's just yet another bench script to add to your arsenal. Included are several tests that I think are most beneficial for the end-user. If there's features that you would like to see added, feel free to submit an issue describing your feature request or fork the project!

## How to Run

`curl https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh | bash`

## Tests Conducted

* **iperf3** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 10 tries, the speed test for that location/direction is skipped.

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2019-10-03                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Thu Oct  3 10:16:52 EDT 2019

Basic System Information:
---------------------------------
Processor: Intel(R) Xeon(R) CPU E5-1650 v3 @ 3.50GHz
CPU cores: 4 @ 3499.732 MHz
RAM      : 1.0G

iperf3 Speed Tests:
---------------------------------
Provider                  | Location (Link)           | Send Speed      | Recv Speed
                          |                           |                 |
Bouygues Telecom          | Paris, FR (10G)           | busy            | busy
Online.net                | Paris, FR (10G)           | 837 Mbits/sec   | 833 Mbits/sec
Severius                  | Netherlands (10G)         | 694 Mbits/sec   | 742 Mbits/sec
Worldstream               | Netherlands (10G)         | 773 Mbits/sec   | 668 Mbits/sec
wilhelm.tel               | Hamburg, DE (10G)         | busy            | busy
Biznet                    | Bogor, ID (1G)            | 288 Mbits/sec   | 318 Mbits/sec
Velocity Online           | Tallahassee, FL, US (?G)  | 906 Mbits/sec   | 854 Mbits/sec
Airstream Communications  | Eau Claire, WI, US (10G)  | 880 Mbits/sec   | 654 Mbits/sec
Hurricane Electric        | Fremont, CA, US (1G)      | 632 Mbits/sec   | busy
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

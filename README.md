# Yet-Another-Bench-Script

Presenting an attempt to create _yet another_ Linux server *bench*marking _script_...

![](https://user-images.githubusercontent.com/8313125/106475387-e1f6da00-6473-11eb-918c-c785ebeef8b9.jpg)
Logo design by [Dian Pratama](https://github.com/dianp)

This script automates the execution of the best benchmarking tools in the industry. Included are several tests to check the performance of critical areas of a server: disk performance with [fio](https://github.com/axboe/fio), network performance with [iperf3](https://github.com/esnet/iperf), and CPU/memory performance with [Geekbench](https://www.geekbench.com/). The script is designed to not require any external dependencies to be installed nor elevated privileges to run. If there are any features that you would like to see added, feel free to submit an issue describing your feature request or fork the project and submit a PR!

### **What's New With YABS?**
* [27 Feb 2023](https://github.com/masonr/yet-another-bench-script/commit/06eaa2ab3b32355bec8278c51c4be93b3662a96d) - Newly released [Geekbench 6](https://www.geekbench.com/) is added as the default Geekbench test.
* [26 Feb 2023](https://github.com/masonr/yet-another-bench-script/commit/f075baf59c3057983fff0a30ea0c746b5ea88d91) - Network information added to YABS output using [ip-api](https://ip-api.com/).
* [15 Aug 2022](https://github.com/masonr/yet-another-bench-script/commit/ae24e70fbf7a4848e81a70cf829ec44e060e63d5) - Added JSON output/upload support to export or auto-upload of YABS results for sharing.

## How to Run

```
curl -sL yabs.sh | bash
```

or 

```
wget -qO- yabs.sh | bash
```

**Local fio/iperf3 Packages**: If the tested system has fio and/or iperf3 already installed, the local package will take precedence over the precompiled binary.

**Experimental ARM Compatibility**: Initial ARM compatibility has been introduced, however, is not considered entirely stable due to limited testing on distinct ARM devices. Report any errors or issues.

**High Bandwidth Usage Notice**: By default, this script will perform many iperf network tests, which will try to max out the network port for ~20s per location (10s in each direction). Low-bandwidth servers (such as a NAT VPS) should consider running this script with the `-r` flag (for reduced iperf locations) or the `-i` flag (to disable network tests entirely).

**Windows Users**: This script can be run on Windows systems by using [Windows Subsystem for Linux v2 (WSL 2)](https://learn.microsoft.com/en-us/windows/wsl/about). WSLv1 will not run the script and binaries correctly.

### Flags (Skipping Tests, Reducing iperf Locations, Geekbench 4/5/6, etc.)

```
curl -sL yabs.sh | bash -s -- -flags
```

| Flag | Description |
| ---- | ----------- |
| -b | Forces use of pre-compiled binaries from repo over local packages |
| -f/-d | Disables the fio (disk performance) test |
| -i | Disables the iperf (network performance) test |
| -g | Disables the Geekbench (system performance) test |
| -n | Skips the network information lookup and print out |
| -h | Prints the help message with usage, flags detected, and local package (fio/iperf) status |
| -r | Reduces the number of iperf locations (Scaleway/Clouvider LON+NYC) to lessen bandwidth usage |
| -4 | Runs a Geekbench 4 test and disables the Geekbench 6 test |
| -5 | Runs a Geekbench 5 test and disables the Geekbench 6 test |
| -9 | Runs both the Geekbench 4 and 5 tests instead of the Geekbench 6 test |
| -6 | Re-enables the Geekbench 6 test if any of the following were used: -4, -5, or -9 (-6 flag must be last to not be overridden) |
| -j | Prints a JSON representation of the results to the screen |
| -w \<filename\> | Writes the JSON results to a file using the file name provided |
| -s \<url\> | Sends a JSON representation of the results to the designated URL(s) (see section below) |

Options can be grouped together to skip multiple tests, i.e. `-fg` to skip the disk and system performance tests (effectively only testing network performance).

**Geekbench License Key**: A Geekbench license key can be utilized during the Geekbench test to unlock all features. Simply put the email and key for the license in a file called _geekbench.license_. `echo "email@domain.com ABCDE-12345-FGHIJ-57890" > geekbench.license`

### Submitting JSON Results

Results from running this script can be sent to your benchmark results website of choice in JSON format. Invoke the `-s` flag and pass the URL to where the results should be submitted to:

```
curl -sL yabs.sh | bash -s -- -s "https://example.com/yabs/post"
```

JSON results can be sent to multiple endpoints by entering each site joined by a comma (e.g. "https://example.com/yabs/post,http://example.com/yabs2/post").

Sites supporting submission of YABS JSON results:

| Website | Example Command |
| --- | --- |
| [YABSdb](https://yabsdb.com/) | `curl -sL yabs.sh \| bash -s -- -s "https://yabsdb.com/add"` |
| [VPSBenchmarks](https://www.vpsbenchmarks.com/yabs/get_started) | `curl -sL yabs.sh \| bash -s -- -s https://www.vpsbenchmarks.com/yabs/upload` |

Example JSON output: [example.json](bin/example.json).

## Tests Conducted

* **[fio](https://github.com/axboe/fio)** - the most comprehensive I/O testing software available, fio grants the ability to evaluate disk performance in a variety of methods with a variety of options. Four random read and write fio disk tests are conducted as part of this script with 4k, 64k, 512k, and 1m block sizes. The tests are designed to evaluate disk throughput in near-real world (using random) scenarios with a 50/50 split (50% reads and 50% writes per test).
* **[iperf3](https://github.com/esnet/iperf)** - the industry standard for testing download and upload speeds to various locations. This script utilizes iperf3 with 8 parallel threads and tests both download and upload speeds. If an iperf server is busy after 5 tries, the speed test for that location/direction is skipped.
* **[Geekbench](https://www.geekbench.com/)** - Geekbench is a benchmarking program that measures system performance, which is widely used in the tech community. The web URL is displayed to be able to see complete test and individual benchmark results and allow comparison to other geekbench'd systems. The claim URL to add the Geekbench result to your Geekbench profile is written to a file in the directory that this script is executed from. By default, Geekbench 6 is the only Geekbench test performed, however, Geekbench 4 and/or 5 can also be toggled on by passing the appropriate flag.

### Security Notice

This script relies on external binaries in order to complete the performance tests. The network (iperf3) and disk (fio) tests use binaries that are compiled by myself utilizing a [Holy Build Box](https://github.com/phusion/holy-build-box) compilation environment to ensure binary portability. The reasons for doing this include ensuring standardized (parsable) output, allowing support of both 32-bit and 64-bit architectures, bypassing the need for prerequisites to be compiled and/or installed, among other reasons. For the system test, a Geekbench tarball is downloaded, extracted, and the resulting binary is run. Use this script at your own risk as you would with any script publicly available on the net. Additional information regarding the binaries, including compilation notes and steps, can be found in the bin directory's [README page](bin/README.md).

## Example Output

```
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
#              Yet-Another-Bench-Script              #
#                     v2023-04-23                    #
# https://github.com/masonr/yet-another-bench-script #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #

Sun 23 Apr 2023 01:41:14 PM EDT

Basic System Information:
---------------------------------
Uptime     : 342 days, 18 hours, 35 minutes
Processor  : Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
CPU cores  : 12 @ 4693.667 MHz
AES-NI     : ✔ Enabled
VM-x/AMD-V : ✔ Enabled
RAM        : 15.5 GiB
Swap       : 14.9 GiB
Disk       : 864.5 GiB
Distro     : Ubuntu 20.04.6 LTS
Kernel     : 5.4.0-110-generic
VM Type    : NONE
IPv4/IPv6  : ✔ Online / ✔ Online

IPv6 Network Information:
---------------------------------
ISP        : Clouvider Limited
ASN        : AS62240 Clouvider
Host       : USA Network
Location   : New York, New York (NY)
Country    : United States

fio Disk Speed Tests (Mixed R/W 50/50):
---------------------------------
Block Size | 4k            (IOPS) | 64k           (IOPS)
  ------   | ---            ----  | ----           ----
Read       | 405.41 MB/s (101.3k) | 407.96 MB/s   (6.3k)
Write      | 406.48 MB/s (101.6k) | 410.11 MB/s   (6.4k)
Total      | 811.90 MB/s (202.9k) | 818.08 MB/s  (12.7k)
           |                      |
Block Size | 512k          (IOPS) | 1m            (IOPS)
  ------   | ---            ----  | ----           ----
Read       | 380.21 MB/s    (742) | 394.55 MB/s    (385)
Write      | 400.41 MB/s    (782) | 420.82 MB/s    (410)
Total      | 780.62 MB/s   (1.5k) | 815.37 MB/s    (795)

iperf3 Network Speed Tests (IPv4):
---------------------------------
Provider        | Location (Link)           | Send Speed      | Recv Speed      | Ping
-----           | -----                     | ----            | ----            | ----
Clouvider       | London, UK (10G)          | 1.61 Gbits/sec  | 2.39 Gbits/sec  | 77.5 ms
Scaleway        | Paris, FR (10G)           | busy            | 2.25 Gbits/sec  | 83.3 ms
Clouvider       | NYC, NY, US (10G)         | 9.10 Gbits/sec  | 8.85 Gbits/sec  | 1.21 ms

iperf3 Network Speed Tests (IPv6):
---------------------------------
Provider        | Location (Link)           | Send Speed      | Recv Speed      | Ping
-----           | -----                     | ----            | ----            | ----
Clouvider       | London, UK (10G)          | 2.00 Gbits/sec  | 21.1 Mbits/sec  | 76.7 ms
Scaleway        | Paris, FR (10G)           | 2.66 Gbits/sec  | 1.56 Gbits/sec  | 75.9 ms
Clouvider       | NYC, NY, US (10G)         | 3.42 Gbits/sec  | 7.80 Gbits/sec  | 1.15 ms

Geekbench 4 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 5949
Multi Core      | 23425
Full Test       | https://browser.geekbench.com/v4/cpu/16746501

Geekbench 5 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 1317
Multi Core      | 5529
Full Test       | https://browser.geekbench.com/v5/cpu/21102444

Geekbench 6 Benchmark Test:
---------------------------------
Test            | Value
                |
Single Core     | 1549
Multi Core      | 5278
Full Test       | https://browser.geekbench.com/v6/cpu/1021916

YABS completed in 12 min 49 sec

```

## Acknowledgements

This script was inspired by several great benchmarking scripts out there, including, but not limited to, [bench.sh](https://bench.sh/), [nench.sh](https://github.com/n-st/nench), [ServerBench](https://github.com/K4Y5/ServerBench), among others. Members of the [HostBalls](https://hostballs.com), [LowEndSpirit](https://lowendspirit.com), and [LowEndTalk](https://lowendtalk.com) hosting-related communities play a pivotal role in testing, evaluating, and shaping this script as it matures.

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

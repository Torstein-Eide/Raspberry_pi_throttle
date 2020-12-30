# Raspberry pi throttle
A small program to display status of the raspberry pi an CPU governor.

## Example output
user friendly
```bash
Status: 0x80000 (conservative)
Status:
Undervolted (<=4.63V): OK
  Freq Capped (>=80c): OK
    Throttled (>=85c): OK
    Throttled (>=60c): Previously
ARM:    Core:   Core Voltage: Core Temp:
600Mhz  250MHz  1.2000V       55.3'C
```


CSV ouput
```bash
ID;date;ClockARM;Clockcore;VoltCore;TEMP;Throttled_status;Undervolted_status
0;2019-08-11 00:00:44;600;250;1.2000;54.8;0;0
1;2019-08-11 00:00:45;600;250;1.2000;54.8;0;0
2;2019-08-11 00:00:46;600;250;1.2000;53.7;0;0
```


## download
```shell
sudo wget  https://raw.githubusercontent.com/Eideen/Raspberry_pi_throttle/master/trottled.sh -O /usr/bin/trottled.sh
sudo chmod +x /usr/bin/trottled.sh
```
## Run without password promt

The following commands, expect that the user running the script is part of the `users`group, run `groups` to list your current groups.
### manuall
```shell
echo "%users ALL=(ALL) NOPASSWD: /usr/bin/trottled.sh" |  tee /etc/sudoers.d/RASP-trottled
```
### Via script
```shell
trottled.sh --install
```

## Run

To run continuously use `sudo trottled.sh -c`

To run once use `sudo trottled.sh -1`

To run with as logging output use `sudo trottled.sh -l`

```shell
Usage: trottled.sh [-c/-1/-l/-h]
Example: 'trottled.sh -c'

Options:
modes:
  -c, --continuously		Loops the cheack every secound. (for monitoring)
  -1, --run-once        Only run once. (for MOTD)
  -l, --logging         Semi-colom list output (for logging)
  -h, --help            Display this help
Options:
  -i, --intervall                  Intevall in seconds. use ".". Default is 1s, minimum is 0.2s.

  CSV output coloms:
  -1 Counter
  -2 Date/time
  -3 ARM core clock
  -4 Core clock
  -5 Core Voltage
  -6 Core temp
  -7 Throttling (
    0=no throttling,
    1=soft_temp_limit(>=60c),
    2=capping(>=80c),
    3=throttling(>=85c))
  -8 Undervolting (
    0=no Undervolting,
    1=Undervolting)
  Previously is not printet in CSV mode.
```

## Definition


## supported OS

* Raspbian (32bit only)

## Add to MOTD
If you like to show the status at loggin, you can use the following command:
```shell
sudo echo -e '#!/bin/sh
echo
trottled.sh -1
echo' | sudo tee /etc/update-motd.d/30-trottled && sudo chmod +x /etc/update-motd.d/30-trottled
```

It is importen that the scipt only run once, or you will be unable to login.

## Requirements
There are no external dependencies.

## License
MIT

## Author Information
See <https://github.com/eideen>

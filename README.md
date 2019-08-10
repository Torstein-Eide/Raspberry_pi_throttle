# Raspberry pi throttle
A small program to display status of the raspberry pi, cpu controll.

## Eksample output
user friendly
```shell
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
```shell
0;2019-08-11 00:00:44;600;250;1.2000;54.8;0;0
1;2019-08-11 00:00:45;600;250;1.2000;54.8;0;0
2;2019-08-11 00:00:46;600;250;1.2000;53.7;0;0
```


## download
```shell
cd /bin/
sudo wget  https://raw.githubusercontent.com/Eideen/Raspberry_pi_throttle/master/trottled.sh
sudo chmod +x trottled.sh
```

## Run

To run continuously use `sudo trottled.sh -c`

To run once use `sudo trottled.sh -o`

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
  -i                    Intevall in seconds. use \".\". Default is 1s, minimum is 0.2s.

  CSV output coloms:
  -1 Counter
  -2 Date/time
  -3 ARM core clock
  -4 Core clock
  -5 Core Voltage
  -6 Core temp
  -7 Throttling (0=no throttling, 1=SOFT_TEMP_LIMIT, 2=capping, 3=throttling)
  Previously is not printet in CSV mode.
```

## Definition


## supported OS

* Raspbian (32bit only)

## Add to MOTD
If you like to show the status at loggin, you can use the following command:
```shell
sudo echo "trottled.sh -o" | sudo tee /etc/update-motd.d/30-trottled && sudo chmod +x /etc/update-motd.d/30-trottled
```

It is importen that the scipt only run once, or you will be unable to login.

## Requirements
There are no external dependencies.

## License
MIT

## Author Information
See <https://github.com/eideen>

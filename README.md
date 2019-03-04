# Raspberry pi throttle
A small program to display status of the raspberry pi, cpu controll.

## Eksample output
```
Status: 0x80000 (conservative)
Status:
Undervolted (<=4.63V): OK
  Freq Capped (>=80c): OK
    Throttled (>=85c): OK
    Throttled (>=60c): Previously
ARM:    Core:   Core Voltage: Core Temp:
600Mhz  250MHz  1.2000V       55.3'C
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

## Definition


## supported OS

* Raspbian (32bit only)

## Add to MOTD
If you like to show the status at loggin, you can use the following command:
```shell
sudo echo "trottled.sh -o" | sudo tee /etc/update-motd.d/30-trottled
```

It is importen that the scipt only run once, or you will be unable to login.

## Requirements
There are no external dependencies.

## License
MIT

## Author Information
See <https://github.com/eideen>

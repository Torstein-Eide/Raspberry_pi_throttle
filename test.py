#!/usr/bin/env python3

#before first run
#run chmod +x ./trottled.py
from typing import NewType


import subprocess
import time
import threading
import sys
import datetime
from typing import Sequence, TypeVar

A = subprocess.check_output(["vcgencmd", "get_throttled"])[10:-1]
STATUS = \xa0000
print (A)

exit()


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

UNDERVOLTED = 0x1
CAPPED = 0x2
THROTTLED = 0x4
HAS_UNDERVOLTED = 0x10000
HAS_CAPPED = 0x20000
HAS_THROTTLED = 0x40000
SOFT_TEMP_LIMIT = 0x8
HAS_SOFT_TEMP_LIMIT = 0x80000
print (HAS_SOFT_TEMP_LIMIT)


GOOD = bcolors.OKGREEN + "NO" + bcolors.ENDC
BAD  = bcolors.FAIL + "YES" + bcolors.ENDC
OK   = bcolors.OKGREEN + "OK" + bcolors.ENDC
PREVIOUSLY = bcolors.WARNING + "Previously" + bcolors.ENDC

# print (bcolors.WARNING + "Warning: No active frommets remain. Continue?"
#       + bcolors.ENDC)
# exit

try:
    s = 0
    def check_vcg():
        GOVENER = subprocess.check_output(["cat", "/sys/devices/system/cpu/cpufreq/policy0/scaling_governor"])[:-1].decode()
        STATUS = subprocess.check_output(["vcgencmd", "get_throttled"])[10:-1]
        TEMP = subprocess.check_output(["vcgencmd", "measure_temp"])[5:-3]
        TEMP = TEMP.decode()
        ClockARM = int(subprocess.check_output(["vcgencmd", "measure_clock arm"])[14:])  / 1000000
        Clockcore = int(subprocess.check_output(["vcgencmd", "measure_clock core"])[13:-1]) / 1000000
        VoltCore = float(subprocess.check_output(["vcgencmd", "measure_volts core"])[5:-2])
        return  GOVENER, STATUS, TEMP, ClockARM, Clockcore, VoltCore;
    def sleeper(n, name):
        time.sleep(n)
    help = "Usage: trottled.sh [-c/-o/-l/-O]\n \
    Example: 'trottled.sh -c'\n \
    \n \
    modes:\n \
      -c, --continuously    Loops the cheack every secound. (for monitoring)\n \
      -1, --run-once        Only run once. (for MOTD)\n \
      -l, --logging         Semi-colom list output (for logging)\n \
      -h, --help            Display this help\n \
    Options:\n \
      -i                    Intevall in seconds. use \".\". Default is 1s, minimum is 0.2s.\n \
    \n \
      CSV output coloms:\n \
      -1 Counter\n \
      -2 Date/time\n \
      -3 ARM core clock\n \
      -4 Core clock\n \
      -5 Core Voltage\n \
      -6 Core temp \n \
      -7 Throttling (0=no throttling, 1=SOFT_TEMP_LIMIT, 2=capping, 3=throttling)\n \
      Previously is not printet in CSV mode.\n"
    time.sleep(0.4)

    # while s <= 49:
    #     x = threading.Thread(target = sleeper, name = 'slp1', args =(0.1, 'sleeper1') )
    #     x.start()
    #     GOVENER,STATUS,TEMP, ClockARM, Clockcore, VoltCore = check_vcg()
    #     print (s, datetime.datetime.now(), GOVENER,STATUS,TEMP, ClockARM, Clockcore, VoltCore)
    #     s = s + 1
    #     x.join()
    def TUI():
        GOVENER,STATUS,TEMP, ClockARM, Clockcore, VoltCore = check_vcg()

        if STATUS != 0:
            print ("Status:", bcolors.FAIL + STATUS + bcolors.ENDC, "(" + GOVENER + ")" )
            print ("Undervolted (<=4.63V): ", end = '')
            a = STATUS & UNDERVOLTED
            b = STATUS & HAS_UNDERVOLTED
            if a != 0:
                print (BAD)
            elif b != 0:
                print (PREVIOUSLY)
            else:
                print (OK)
            print ("  Freq Capped (>=80c): ", end = '')
            if (STATUS & CAPPED) != 0:
                print (BAD)
            elif (STATUS & HAS_CAPPED) != 0:
                print (PREVIOUSLY)
            else:
                print (OK)
        else:
            print ("Status:", bcolors.OKGREEN + STATUS + ", no throttling or capping" + bcolors.ENDC, "(" + GOVENER + ")" )

    if "-h" in str(sys.argv):
        print (help)
        exit
    elif "-1" in str(sys.argv):
        TUI()


        exit()




except KeyboardInterrupt:
    sys.exit(1)

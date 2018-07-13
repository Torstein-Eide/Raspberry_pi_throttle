#!/bin/bash
#before first run
#run chmod +x ./trottled.sh

#Flag Bits
UNDERVOLTED=0x1
CAPPED=0x2
THROTTLED=0x4
HAS_UNDERVOLTED=0x10000
HAS_CAPPED=0x20000
HAS_THROTTLED=0x40000

#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0` #No color

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"



while true;
do

#Get Status, extract hex
STATUS=$(vcgencmd get_throttled)
STATUS=${STATUS#*=}
#Get Temp, extract hex
TEMP=$(vcgencmd measure_temp)
TEMP=${TEMP#*=}


ClockARM=$(vcgencmd measure_clock arm)
ClockARM=$(bc <<< "${ClockARM#*=}/1000000")
Clockcore=$(vcgencmd measure_clock core)
Clockcore=$(bc <<< "${Clockcore#*=}/1000000")

VoltCore=$(vcgencmd measure_voltage core)
VoltCore=${VoltCore#*=}

clear;


echo -n "Status: "
# test, if true do red else grenn
(($STATUS!=0)) && echo "${RED}${STATUS}${NC}" || echo "${GREEN}${STATUS}${NC}"

echo "Undervolted:"
echo -n "   Now: "
((($STATUS&UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Throttled:"
echo -n "   Now: "
((($STATUS&THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Frequency Capped:"
echo -n "   Now: "
((($STATUS&CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo  "ARM:    Core:    Core Voltage:"
echo  "${GREEN}${ClockARM}${NC}Mhz ${GREEN}${Clockcore}${NC}MHz ${GREEN}${VoltCore}${NC}"

sleep 1
done

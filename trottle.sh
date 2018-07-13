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
TEMP=$vcgencmd measure_temp


for src in arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi ;
do 
echo -e "$src:\t$(vcgencmd measure_clock $src)" ;
done

for id in core sdram_c sdram_i sdram_p ; do \
echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
done




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


sleep 5
done


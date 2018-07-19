#!/bin/bash
#before first run
#run chmod +x ./trottled.sh
if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as user: root"
        exit -1
fi

#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0` #No color
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}ERROR: You must be a root user${NC}" 2>&1
  exit 1
fi
if hash bc  2>/dev/null; then
        echo "bc installed"
    else
        echo "${RED}ERROR: bc not installed, ${NC}run 'sudo apt update; sudo apt install bc'"
        exit
    fi


#Flag Bits
UNDERVOLTED=0x1
CAPPED=0x2
THROTTLED=0x4
HAS_UNDERVOLTED=0x10000
HAS_CAPPED=0x20000
HAS_THROTTLED=0x40000



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

VoltCore=$(vcgencmd measure_volts core)
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

echo  "ARM:	Core:	Core Voltage:	Core Temp:"
echo  "${GREEN}${ClockARM}${NC}Mhz	${GREEN}${Clockcore}${NC}MHz	${GREEN}${VoltCore}${NC}		${GREEN}${TEMP}${NC}"

sleep 1 
done

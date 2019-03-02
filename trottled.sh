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
SOFT_TEMP_LIMIT=0x8
HAS_SOFT_TEMP_LIMIT=0x80000

#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0` #No color

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"
OK="${GREEN}OK${NC}"


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

# test, if true do red else grenn
echo -n "Status: "
(($STATUS!=0)) && echo "${RED}${STATUS}${NC}" || echo "${GREEN}${STATUS}, no throttling or capping ${NC}"

if [ $STATUS!=0 ];
	then
	echo "Status: "

	if ((($STATUS&HAS_UNDERVOLTED)!=0))
		then
			echo "Undervolted:"
			echo -n "   Now: "
			((($STATUS&UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"
			echo -n "   Run: "
			((($STATUS&HAS_UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"
		else
			echo "Undervolted:	${OK}"
	fi
	if 	((($STATUS&HAS_THROTTLED)!=0))
		then
			echo "Throttled:"
			echo -n "   Now: "
			((($STATUS&THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"
			echo -n "   Run: "
			((($STATUS&HAS_THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"
		else
			echo "Throttled:	${OK}"
	fi
	if ((($STATUS&HAS_CAPPED)!=0))
	then
		echo "Frequency Capped:"
		echo -n "   Now: "
		((($STATUS&CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"
		echo -n "   Run: "
		((($STATUS&HAS_CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"
	else
		echo "Freq Capped:	${OK}"
	fi

	if ((($STATUS & HAS_SOFT_TEMP_LIMIT)!=0))
		then
			echo "Temp over 60c:"
		echo -n "   Now: "
		((($STATUS & SOFT_TEMP_LIMIT)!=0)) && echo "${BAD}" || echo "${GOOD}"
		echo -n "   Run: "
		((($STATUS & HAS_SOFT_TEMP_LIMIT)!=0)) && echo "${BAD}" || echo "${GOOD}"
	else
		echo "Temp over 60c:	${OK}"
	fi

fi


echo  "ARM:	Core:	Core Voltage:	Core Temp:"
echo  "${GREEN}${ClockARM}${NC}Mhz	${GREEN}${Clockcore}${NC}MHz	${GREEN}${VoltCore}${NC}		${GREEN}${TEMP}${NC}"

sleep 1
done

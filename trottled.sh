#!/bin/bash
#before first run
#run chmod +x ./trottled.sh
help="Usage: trottled.sh [-c/-o]\n
Example: 'trottled.sh -c'\n
\n
Options:\n
  -c		loops the cheack every secound. (for monitoring)\n
  -o		only run once. (for MOTD)
"
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
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0` #No color

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"
OK="${GREEN}OK${NC}"
PREVIOUSLY="${YELLOW}Previously${NC}"

function check_vcg {

  GOVENER=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)
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

# test, if true do red else grenn
clear;
echo -n "Status: "
(($STATUS!=0)) && echo "${RED}${STATUS}${NC} ($GOVENER)" || echo "${GREEN}${STATUS}, no throttling or capping ${NC}"

if [ $STATUS!=0 ];
	then
		echo "Status: "
    echo -n "Undervolted (<=4.63V): "
	if ((($STATUS&UNDERVOLTED)!=0));	then
    echo "${BAD}"
  elif ((($STATUS&HAS_UNDERVOLTED)!=0)); then
    echo "${PREVIOUSLY}"
  else
    echo "${OK}"
	fi

  echo -n "  Freq Capped (>=80c): "

	if ((( $STATUS&CAPPED)!=0));	then
    echo  "${BAD}"
  elif 	((($STATUS&HAS_CAPPED)!=0)); then
    echo "${PREVIOUSLY}"
	else
			echo "${OK}"
	fi
  echo -n "    Throttled (>=85c): "

  if 	((( $STATUS&THROTTLED)!=0)); then
    echo  "${BAD}"
  elif ((( $STATUS &  HAS_THROTTLED)!=0)); then
    echo "${PREVIOUSLY}"
	else
		echo "${OK}"
	fi
  echo -n "    Throttled (>=60c): "

	if ((( $STATUS & SOFT_TEMP_LIMIT)!=0)); then
    echo "${BAD}"
  elif ((( $STATUS & HAS_SOFT_TEMP_LIMIT)!=0)); then
    echo "${PREVIOUSLY}"
	else
    echo "${OK}"
	fi

fi
#echo
echo  "ARM:	Core:	Core Voltage:	Core Temp:"
echo  "${GREEN}${ClockARM}${NC}Mhz	${GREEN}${Clockcore}${NC}MHz	${GREEN}${VoltCore}${NC}		${GREEN}${TEMP}${NC}"

}

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}ERROR: You must run progam as root user${NC}" 2>&1
  exit 1
fi

if [[ $1 = "-c" ]]; then
	while true; do
			check_vcg
			sleep 1
	done
elif [[ $1 = "-o" ]]; then
	check_vcg
	exit
else
	echo -e $help
	exit
fi

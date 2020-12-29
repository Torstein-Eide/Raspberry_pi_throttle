#!/bin/bash
#before first run
#run chmod +x ./trottled.sh
####################### HELP ###############
help="Usage: trottled.sh [-c/-o/-l/-O]\n
Example: 'trottled.sh -c'\n
\n
Options:\n
modes:\n
  -c, --continuously		Loops the cheack every secound. (for monitoring)\n
  -1, --run-once        Only run once. (for MOTD)\n
  -l, --logging         Semi-colom list output (for logging)\n
  -h, --help            Display this help\n
Options:\n
  -i --intervall                    Intevall in seconds. use \".\". Default is 1s, minimum is 0.2s.\n
\n
  CSV output coloms:\n
  -1 Counter\n
  -2 Date/time\n
  -3 ARM core clock\n
  -4 Core clock\n
  -5 Core Voltage\n
  -6 Core temp \n
  -7 Throttling (0=no throttling, 1=soft_temp_limit(>=60c), 2=capping(>=80c), 3=throttling(>=85c) )\n
  -8 Undervolting (0=no Undervolting, 1=Undervolting) \n
  Previously is not printet in CSV mode.
"
####################### HELP ###############

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

GOVENER=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)
function check_vcg {


  #Get Status, extract hex
  STATUS=$(vcgencmd get_throttled)
  STATUS=${STATUS#*=}


  #Get Temp, extract hex
  TEMP=$(vcgencmd measure_temp)
  TEMP=${TEMP#*=}
  TEMP=${TEMP%\'C}


  ClockARM=$(vcgencmd measure_clock arm)
  ClockARM=$(( ${ClockARM#*=} / 1000000 ))
  Clockcore=$(vcgencmd measure_clock core)
  Clockcore=$((${Clockcore#*=} / 1000000))

  VoltCore=$(vcgencmd measure_volts core)
  VoltCore=${VoltCore#*=}
  VoltCore=${VoltCore%V}
}

function TUI  {
  #statements
check_vcg
clear;
echo -n "Status: "
(($STATUS!=0)) && echo "${RED}${STATUS}${NC} ($GOVENER)" || echo "${GREEN}${STATUS}, no throttling or capping ${NC} ($GOVENER) "

if (($STATUS!=0));
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
echo  "${GREEN}${ClockARM}${NC}Mhz	${GREEN}${Clockcore}${NC}MHz	${GREEN}${VoltCore}${NC}V		${GREEN}${TEMP}${NC}'C"
}
function CSV {
  # function for CSV output
  check_vcg
  dt=$(date +%Y-%m-%d\ %T${DT_format})

  ## Undervolting
  if ((($STATUS&UNDERVOLTED)!=0));	then
    UNDERVOLTED_true=1
  else
    UNDERVOLTED_true=0
  fi

  ## Throttling
  if ((( $STATUS & SOFT_TEMP_LIMIT)!=0)); then
    THROTTLED_true=1
  elif ((( $STATUS&CAPPED)!=0));	then
    THROTTLED_true=2
  elif ((( $STATUS&THROTTLED)!=0)); then
    THROTTLED_true=3
  else
    THROTTLED_true=0
  fi
## ${UNDERVOLTED_true};${CAPPED_true};${THROTTLED_true};${SOFT_TEMP_LIMIT_true}


  echo  "$c;$dt;${ClockARM};${Clockcore};${VoltCore};${TEMP};${THROTTLED_true};${UNDERVOLTED_true}"
}



function mode-test {
  if  [[ -n $mode ]]; then echo "multiple modes selected. Make up your mind! please try again" ; exit 11; fi
}

# change for intervall parameter.

        c=0
intervall=1

# test if root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}ERROR: You must run progam as root user${NC}" 2>&1
  exit 10
fi

if  [ -z "$*" ]; then
  echo -e "You forgot argruments!\n printing help"
  echo -e $help
	exit 11
fi

TEMP=`getopt -o hcl1i: --long install,help,continuously,logging,run-once,single,intervall:outputfile: \
             -n 'javawrap' -- "$@"`

eval set -- "$TEMP"

while  [[ $# -gt 0 ||  "$1" == "--"*  ]] ;
do
    opt="$1";
    case "$opt" in
        "--")  break;;
        "--help"| "-h")
           echo -e  $help ; exit;;
        '-c' | '--continuously')
          mode-test
          mode="continuously";  shift;;
        '-1' | '--single' | '--run-once')
           mode-test
           mode="single";  shift;;
        '-l' | '--logging')
           mode-test
           mode="logg";  shift;;
         -i | --intervall )  intervall="$2";
         # test if number is valid
						re='^[0-9]+(\.\d+)?'
						if ! [[ $intervall =~ $re ]] ; then
                     echo "-i $intervall is not a number" && exit 11
						elif [[ $intervall < 0.2 ]]; then
				         echo "intervall is to low, script is not optimisted for intervall below 0.2s"
						   exit 14
						elif [[ $intervall < 1 ]]; then
						   DT_format='.%N'
						else
						   DT_format=''
						fi
						shift 2 ;;
			 "--install" )
  			 echo -e "making it possible to run as normal user, without passord\n editing /etc/sudoers.d/RASP-trottled"
  			 echo "%users ALL=(ALL) NOPASSWD: /usr/bin/trottled.sh" |  tee /etc/sudoers.d/RASP-trottled
  			 exit ;;
        *) echo >&2 "Invalid option: $opt"; exit 11;;
   esac
done


## run in mode
if [[ $mode = 'continuously' ]]; then
	while true; do
			sleep $intervall &
      TUI
      let c=c+1
      wait
	done
elif [[ $mode == 'logg' ]]; then
   #$c;$dt;${ClockARM};${Clockcore};${VoltCore};${TEMP};${THROTTLED_true};${UNDERVOLTED_true}
  echo "ID;date;ClockARM;Clockcore;VoltCore;TEMP;Throttled_status;Undervolted_status"

  while true; do
      sleep $intervall &
      CSV
      let c=c+1
      wait
	done
elif [[ $mode == 'single' ]]; then
	TUI
	exit
else
echo "Modes not selected. Make up your mind! Please try again" ; exit 11; fi

fi

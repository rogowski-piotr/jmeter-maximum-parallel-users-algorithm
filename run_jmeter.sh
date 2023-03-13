#!/bin/bash


#################################
#           FUNCTIONS           #
#################################
helpFunction()
{
    echo ""
    echo "Usage: $0 [-i <integer> (required)] [-a <integer> (required)] [-b <integer> (required)] [-s <integer> (optional)]"
    echo -e "\t-i Number of iterations at algorithm"
	echo -e "\t-a Number of parallel users at first step"
    echo -e "\t-b Number of parallel users at last step"
	echo -e "\t-s Sleep between steps (default 5 seconds)"
    exit 1
}


#################################
#        PARSE VARIABLES        #
#################################
JMETER_PATH="/D/Programy/JMeter/apache-jmeter-5.5/bin/jmeter.sh"
SLEEP_DURATION=5

while getopts "i:a:b:s:" opt
do
    case "$opt" in
        i ) ITERATIONS="$OPTARG" ;;
        a ) USERS_FIRST_STEP="$OPTARG" ;;
		b ) USERS_LAST_STEP="$OPTARG" ;;
		s ) SLEEP_DURATION="$OPTARG" ;;
        ? ) helpFunction ;;
    esac
done


#################################
#             START             #
#################################
for iteration in `seq 1 $ITERATIONS`; do
	mkdir $iteration
	
	for users in `seq $USERS_FIRST_STEP $USERS_LAST_STEP`; do
		eval $JMETER_PATH -n -t Pi2_parametrised.jmx -l log.jtl -Jusers=$users -Jiteration=$iteration
		sleep $SLEEP_DURATION
	done;
done;
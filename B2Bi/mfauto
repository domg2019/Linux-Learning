##########################################################################################################
#This script aims to run the Massfilter files (less than 2000) automatilly to improve the work efficiance 
#
#
#
#	12/16/2019      -Luis  Impleted the function. add the scripts to check shift end time point
#	11/1/2019 	-Luis  Updated. Checking Massfilter files count
#       8/31/2019 	-Luis  Added this script to record the MassFilter files' Value
##########################################################################################################

#!/bin/bash
. $FRAME_ROOT/framework/LHScriptFunctions
. /home/b2bi/alias_B2Bi 1>/dev/null

MASSAUTO=/app/sword/schenker/support/luis/MASSAUTO
Error=/app/sword/schenker/data/error

Year=$(date '+%Y');
Today=$(date '+%Y_%m%d');

while (true);
do	if [ ! -d  "$MASSAUTO/$Year/$Today" ]
	then mkdir -p $MASSAUTO/$Year/$Today;
	fi 

	if   [[ "$(ls $Error/MassFilter* | wc -l | bc )" != 0 && "$(ls $Error/MassFilter* | wc -l | bc )" -le 1800 ]]
			then	echo "Massfilter files come";
					Count=$(ls $Error/MassFilter* | awk -F. '{print $2}' | uniq | wc -l | bc);
					for i in $(seq $Count);
					do  PID=$(ls $Error/MassFilter* | awk -F. '{print $2}' | uniq | sort | sed -n "$i"p);
                        touch $MASSAUTO/$Year/$Today/$PID.txt;
						runmass $PID >> $MASSAUTO/$Year/$Today/$PID.txt;
					done
			else	echo  "++++++++++++++++++++++++++";
	fi      2>/dev/null;
echo "Running completed!"
echo -e "Next check will be executed 100 seconds later.\nPress Enter to check again immediately or <CTRL>+C to stop the script!"
sleep 100;

done;

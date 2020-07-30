#!/bin/bash

##########################################################################################################
#Program:	This script aims to run the Massfilter files (less than 2000) automatilly to improve the work efficiance 
#Author:	Luis Liu   luis.liu@dbschenker.com
#History:
#
#	7/30/2020	-Luis		Update that the script will exist when the average single file is bigger than 10M
#	12/16/2019	-Luis		Impleted the function. add the scripts to check shift end time point
#	11/1/2019	-Luis		Updated. Checking Massfilter files count
#  	8/31/2019 	-Luis		Added this script to record the MassFilter files' Value
##########################################################################################################

#script works only when luis login
user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit

. $FRAME_ROOT/framework/LHScriptFunctions
#. /home/b2bi/alias_B2Bi 1>/dev/null

MASSAUTO=/app/sword/schenker/support/luis/MASSAUTO
Error=/app/sword/schenker/data/error

Year=$(date '+%Y');
Today=$(date '+%Y_%m%d');
#judge if the folder is bigger than 100M
SIZE=`du MASSAUTO|awk 'BEGIN{size=0}{size+=$1}END{print size/1024/1024}'|cut -d. -f1`
[ $SIZE -ge 100 ] && echo -e "The folder bigger than 100M. Kindly inform luis and then continue" && exit 10

#Only hanle files less than 1800 and average file size is less than 1800
[ "$(ls $Error/MassFilter* | wc -l | bc )" -gt 1800 ] && "More than 1800 MassFilter files arrived. Please handle them automatically!!!" && exit 10
M_count=`ls $Error/MassFilter*arc|wc -l|bc`
S_size=`l $Error/MassFilter*arc|awk 'BEGIN{size=0}{size+=$5}END{print size/1024/1024}'|cut -d. -f1`
[ $S_size -ge 10 ] && echo -e "Single file size is bigger than 10 M. Kindly handle them manually."

#copy this function from alias   
function runmass()
{
#    . $FRAME_ROOT/framework/LHScriptFunctions;
    if [[ $1 != '' ]]; then
        if [[ -e "/tmp/remafi_$1.lck" ]];then
            echo "Remafi lock for $1(/tmp/remafi_$1.lck) already exist, probably someone is running remafi."
			  for deviceid in $(who| grep -v "^Login" | awk '{print $2}')
				do
                count=$(ps -ef | grep -w ${deviceid} | grep -v "grep" | grep -c "remafi");
                if [[ ${count} != 0 ]]; then
                    who | grep -w ${deviceid};
                    ps -ef | grep -w ${deviceid} | grep -v "grep" | grep "remafi";
                fi
            done
        else
            err;
            echo -n "MassFilterFileNumber of $1:";
            ls -l /app/sword/schenker/data/error | grep "MassFilter" | grep $1 | grep -c ".att$";
            ls -l /app/sword/schenker/data/error | grep "MassFilter" | grep $1 | head;
            INTEGRATIONTYPE=$(SQLselect INTEGRATIONTYPE XIB_PROCESSIDPROPERTIES PROCESSIDCODE $1 | sed 's#^.* ##');
            echo "Integration type : ${INTEGRATIONTYPE}";
            if [[ "${INTEGRATIONTYPE}" == "Parallel" ]];then
                echo -e "\n>>>deletemassfilterflag $1";
                echo | /app/sword/schenker/toolslocal/support/deletemassfilterflag $1;
                echo -e "\n>>>remafi $1 2";
                /app/sword/schenker/toolslocal/support/remafi $1 2;
            elif [[ "${INTEGRATIONTYPE}" == "SerialLarge" ]]; then
                echo -e "\n>>>remafi $1 7";
                /app/sword/schenker/toolslocal/support/remafi $1 7;
                echo -e "\n>>>deletemassfilterflag $1";
                echo | /app/sword/schenker/toolslocal/support/deletemassfilterflag $1;
            fi
        fi
    fi

}

while (true);
do	

#	check if it's the end of the shift. notice the winter time and summer time is different.
  clear;date;
	wstime=`date +%m`
	time=`date +%H`
	if [[ "$wstime" == "10" || "$wstime" == "11" || "$wstime" == "12" || "$wstime" == "01" || "$wstime" == "02" || "$wstime" == "03" ]]
	then if [[ "$time" == "08" || "$time" == "16" || "$time" == "00" ]]
		then echo -e "It's already the end of this shift........"
		exit 10
		fi
	else if [[ "$time" == "09" || "$time" == "17" || "$time" == "01" ]]
		then echo -e "It's already the end of this shift........"
		exit 10
		fi
	fi

#delete the file that old than 30 days.
	find ./MASSAUTO/ -type f -mtime +30 -exec rm -rf {} \;

	
#	create one today folder to save the remafi history.	
	if [ ! -d  "$MASSAUTO/$Year/$Today" ]
	then mkdir -p $MASSAUTO/$Year/$Today;
	fi 

	if   [[ "$(ls $Error/MassFilter* | wc -l | bc )" != 0 && "$(ls $Error/MassFilter* | wc -l | bc )" -le 1800 ]]
			then	echo -e "Massfilter files come.....";
					Count=$(ls $Error/MassFilter* | awk -F. '{print $2}' | uniq | wc -l | bc);
					for i in $(seq $Count);
					do  PID=$(ls $Error/MassFilter* | awk -F. '{print $2}' | uniq | sort | sed -n "$i"p);
                        touch $MASSAUTO/$Year/$Today/$PID.txt;
						runmass $PID >> $MASSAUTO/$Year/$Today/$PID.txt;
					done
					echo "Running completed!"
			elif [[ "$(ls $Error/MassFilter* | wc -l | bc )" -gt 1800 ]] ;then
			      echo -e "More than 1800 MassFilter files arrived. Please handle them automatically!!!"
			else	echo -e "No MassFilter files arrived";
	fi      2>/dev/null;

#	set the loop function
	echo -e "Next check will be executed 10 minutes later.\nPress Enter to check again immediately or <CTRL>+C to stop it."
	read -t 600 command
	if [ "$command" == "" ];
	then continue
	fi

done;

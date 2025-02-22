#!/bin/bash

######################################################################################
#
#	2019.12.27		-1h			change the loop judgement. reduce the optional time range 
#	2019.12.09		-1h			optimze function, like change time unit...
#	2019.11.26		-0.5h		Add loop function, usage: monitor.sh 300
#	2019.11.23		-1h			Add server choose/task choose function 
#	2019.11.20		-1h   		Imply the function to grep all old files
#	2019.11.18	  	-0.5h 		To filter imp folder agrs & remote hosts to OPS
######################################################################################

#echo "there is work load issue caused by this script, will exit";
#exit;

#script works only when luis login
#user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
#[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit


CONFIG=/app/sword/schenker/support/luis/config
TOOLSUPPORT=/app/sword/schenker/toolslocal/support

function ComChoose()
{
printf "%s\t%s\t%s\t%s\n" `cat $CONFIG/tmp`
echo -e "COMS1_01/03/04/05/06:t1\\t\\tCOMS1_02/07/L1/L2/L3...COMS2_01/L1:t2"
echo -e "You can input all to check all instances!"
read -t 30 -p "Please choose which instance:  " INSTANCE
}

function ErroCheck()
{
	echo -e "######################################################################################################################"
	/app/sword/schenker/toolslocal/support/clean_up2 -v
	echo -en "\033[42;37m  Errors left after the clean_up2 -v:  \033[0m"
	ls /app/sword/schenker/data/error|wc -l;
	if [ `ls /app/sword/schenker/data/error|wc -l` -gt 10 ]
		then  ls -lht /app/sword/schenker/data/error|grep -v total 
		else   ls -lht /app/sword/schenker/data/error| tail -10
		
	fi	
}

function PrintLine2()
{
echo -e "######################################################################################################################"
}


function optSystemCheck()
{
if [[ -z $INSTANCE || $INSTANCE == "all" ]]
	then 	echo -e "It will check all instances..."
			$TOOLSUPPORT/listcs -fileagemin=30
			ErroCheck
			date
			echo -e "Completed. No loop check for list all instances"
			exit 
	elif [ $INSTANCE == "t1" ]
	then  echo -e "##################LISTCS CHECKING###################";date
		  for t1_instance in `cat $CONFIG/t1config.txt`
		  do echo -e  "\033[42;37m  The Result Of:  \033[0m" $t1_instance
		  $TOOLSUPPORT/listcs -comsys=$t1_instance -fileagemin=30 |  sed '/^ERROR.*/,+10d'
		  done		  
		  ErroCheck
		date
	elif [ $INSTANCE == "t2" ]
	then  echo -e "##################LISTCS CHECKING###################";date
		  for t2_instance in `cat $CONFIG/t2config.txt`
		  do echo -e "\033[42;37m  the result of:  \033[0m"  $t2_instance
		  $TOOLSUPPORT/listcs -comsys=$t2_instance -fileagemin=30 | sed '/^ERROR.*/,+10d'
		  done		  
		  ErroCheck
		date
   	 elif [ "$INSTANCE" == "ftp" ]   
	 then listftp -fileagemin=30|sed -n '/Customer directories (DOWNLOAD)/,/Customer directories (UPLOAD)/p'
		date
	elif [ `grep $INSTANCE $CONFIG/tmp` ]
	then COMSYS=`grep $INSTANCE $CONFIG/tmp | cut -d: -f1`
		  $TOOLSUPPORT/listcs -comsys=$COMSYS -fileagemin=30
		  ErroCheck
	else echo "Please input correct value"
fi


}


function optmonitor()
{		
#add the function to judge how many listcs are running the same time. 
		[ `ps -ef|grep -w 'listcs'|grep -v 'grep'|wc -l|bc` -ge 4 ] && echo "alread more than 4 listcs are running" && exit
		[ `w | sed -n 1p|cut -d, -f6|cut -d. -f1|bc` -ge 9 ] && echo "System load high. Function forbidden" && exit 
		INPUT=`echo $1|bc`
		if [ "$INPUT" == "" ]
		then 	ComChoose
			optSystemCheck
		elif [[ "$INPUT" -gt 60 || "$INPUT"  -lt 30 ]]
			then echo -e "Please input the monitor time value between 30-60 (min)"
			else
				ComChoose
#set the loop time 20 as default 
				for((looptime=1;looptime<=16;looptime++));do
				clear
				optSystemCheck
				CkTime=$(( $1*60 ))
				echo -e "Next check will be executed $INPUT mins later.\nPress Enter to check again immediately or <CTRL>+C to stop it."	
				read -t "$CkTime"
				done
		fi
}			 

optmonitor $@

#!/bin/bash

######################################################################################
#
#
#	2019.12.09		-1h		optimze function, like change time unit...
#	2019.11.26		-0.5h		Add loop function, usage: monitor.sh 300
#	2019.11.23		-1h			Add server choose/task choose function 
#	2019.11.20		-1h   		Imply the function to grep all old files
#	2019.11.18	  	-0.5h 		To filter imp folder agrs & remote hosts to OPS
######################################################################################

echo "there is work load issue caused by this script, will exit";
exit;

alias grep='grep --color==auto'

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
	echo -en "Errors left after the clean_up2 -v:"
	ls /app/sword/schenker/data/error|wc -l;
	if [ `ls /app/sword/schenker/data/error|wc -l` -gt 10 ]
		then  ls -lht /app/sword/schenker/data/error
		else   ls -lht /app/sword/schenker/data/error| tail -10
		
	fi	
}

function PrintLine2()
{
echo -e "######################################################################################################################"
}

function Impfile()
{
	impno=`grep -n $i/impwork $CONFIG/listcs.txt|cut -d: -f1`
	high=`grep total $CONFIG/listcs.txt|wc -l|bc`
	for((j=1;j<=$high;j++))
	do ttno=`grep -n total $CONFIG/listcs.txt|sed -n "$j"p|cut -d: -f1`
	if [ "$ttno" -gt "$impno" ]
	then sed -n "$impno","$ttno"p $CONFIG/listcs.txt
	echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	continue 2
	fi 2>/dev/null
	done
}

function SystemCheck()
{


if [[ -z $INSTANCE || $INSTANCE == "all" ]]
	then 	echo -e "It will check all instances..."
			$TOOLSUPPORT/listcs -fileagemin=30
			ErroCheck
			date
	elif [ $INSTANCE == "t1" ]
	then  echo -e "##################LISTCS CHECKING###################";date
		  echo "checking..."
		  $TOOLSUPPORT/listcs -fileagemin=30 >  $CONFIG/listcs.txt
		  for i in `cat $CONFIG/t1config.txt`
		  do Impfile;done
		  PrintLine2
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 5 $i/catlist $CONFIG/listcs.txt;done
		  PrintLine2
		  echo -e "Outbound Agreement Directories (please standby..)"
		  PrintLine2
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 5 $i $CONFIG/listcs.txt | grep -A 5 '/imp:';done	
		  PrintLine2
		  echo -e "Inbound Agreement Directories (please standby...)"
		  PrintLine2
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 5 inbound $CONFIG/listcs.txt | grep -A 5 $i ;done	
		  ErroCheck
		date
	elif [ $INSTANCE == "t2" ]
	then  echo -e "##################LISTCS CHECKING###################";date
		  echo "checking..."
		  $TOOLSUPPORT/listcs -fileagemin=30 >  $CONFIG/listcs.txt
		  for i in `cat $CONFIG/t2config.txt`
		  do Impfile;done
		  PrintLine2
		  for i in `cat $CONFIG/t2config.txt`
		  do grep -A 5 $i/catlist $CONFIG/listcs.txt ;done
		  PrintLine2
		  echo -e "Outbound Agreement Directories (please standby..)"
		  PrintLine2
		  for i in `cat $CONFIG/t2config.txt`
		  do grep -A 5 $i $CONFIG/listcs.txt | grep -A 5 '/imp:';done	
		  PrintLine2
		  echo -e "Inbound Agreement Directories (please standby...)"
		  PrintLine2
		  for i in `cat $CONFIG/t2config.txt`
		  do grep -A 5 inbound $CONFIG/listcs.txt | grep -A 5 $i ;done	
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


function monitor()
{		
		INPUT=`echo $1|bc`
		if [ "$INPUT" == "" ]
		then 	ComChoose
			SystemCheck
		elif [[ "$INPUT" -gt 120 || "$INPUT"  -lt 5 ]]
			then echo -e "Please input the monitor time value between 5-120 (min)"
			else
				ComChoose
				while true;do
				SystemCheck
				CkTime=$(( $1*60 ))
				echo -e "Next check will be executed $INPUT mins later.\nPress Enter to check again immediately or <CTRL>+C to stop it."	
				read -t "$CkTime"
				done
		fi
}			 

monitor $@

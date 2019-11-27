#!/bin/bash

######################################################################################
#
#
#
#	2019.11.26		-0.5h		Add loop function, usage: monitor.sh 300
#	2019.11.23		-1h			Add server choose/task choose function 
#	2019.11.20		-1h   		Imply the function to grep all old files
#	2019.11.18  	-0.5h 		To filter imp folder agrs & remote hosts to OPS
######################################################################################


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
		then  ls -lht /app/sword/schenker/data/error|wc -l
		else   ls -lht /app/sword/schenker/data/error| tail -10
		
	fi	
}

function PrintLine2()
{
echo -e "######################################################################################################################"
echo -e "Inbound Agreement Directories (please standby...)"
echo -e "######################################################################################################################"
}


function SystemCheck()
{

ComChoose
if [[ -z $INSTANCE || $INSTANCE == "all" ]]
	then 	echo -e "It will check all instances..."
			$TOOLSUPPORT/listcs -fileagemin=30
			ErroCheck
	elif [ $INSTANCE == "t1" ]
	then  echo -e "##################LISTCS CHECKING###################";date
		  $TOOLSUPPORT/listcs -fileagemin=30 >  $CONFIG/listcs.txt
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 18 $i $CONFIG/listcs.txt | grep -A 18 '/impwork:';done
		  echo -e "**********************************************************************************************************************"
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 5 $i $CONFIG/listcs.txt | grep -A 5 '/imp:';done	
		  PrintLine2
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 5 inbound $CONFIG/listcs.txt | grep -A 5 $i ;done	
		  ErroCheck
	elif [ $INSTANCE == "t2" ]
	then  echo -e "##################LISTCS CHECKING###################";date
		  $TOOLSUPPORT/listcs -fileagemin=30 >  $CONFIG/listcs.txt
		  for i in `cat $CONFIG/t2config.txt`
		  do grep -A 18 $i $CONFIG/listcs.txt | grep -A 18 '/impwork:';done
		  echo -e "**********************************************************************************************************************"
		  for i in `cat $CONFIG/t2config.txt`
		  do grep -A 5 $i $CONFIG/listcs.txt | grep -A 5 '/imp:';done	
		  PrintLine2
		  for i in `cat $CONFIG/t1config.txt`
		  do grep -A 5 inbound $CONFIG/listcs.txt | grep -A 5 $i ;done	
		  ErroCheck
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
		then SystemCheck
		elif [[ "$INPUT" -gt 120 || "$INPUT"  -lt 5 ]]
			then echo -e "Please input the monitor time value between 5-120 (min)"
			else
				while true;do
				SystemCheck
				CkTime=$(( $1*60 ))
				echo -e "Next check will be executed $INPUT mins later.\nPress Enter to check again immediately or <CTRL>+C to stop it."	
				read -t "$CkTime"
				done
		fi
}			 

monitor $@

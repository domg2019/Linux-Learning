#!/bin/bash

###########################################################
#Program:	Create this script to handle exp files automatically.
#History:	2020.01.08	Luis	Release
#
###########################################################

#script works only when luis login
user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit


COM=/app/sword/schenker/comsys

#advise to input the correct filename
ls ${COM}/COMS*/agr/*outbound/imp/$1 &>/dev/null
if [[ -z "$1" || $? -ne 0  ]]
then echo -e "Please input the whole inbound file name."
exit 
fi

agreement=`echo $1|cut -d. -f1`
imp_directory=`dirname ${COM}/COMS*/agr/*outbound/imp/$1`
agr_directory=${imp_directory%/*}


#echo the current pending file
echo -e ">>>pending file as below:"
echo -e "**********************************************************************************************************************"
echo -en `dirname ${COM}/COMS*/agr/*outbound/imp/$1`:
echo -en "\t pending files: "; find $imp_directory -mmin +30 -type f|wc -l
echo -e "**********************************************************************************************************************"
echo -en "     oldest file:";ls -lt $imp_directory/${agreement}* | tail -1|sed 's/\(.*\ \)\/app.*imp\//\1/'
echo -en "most recent file:";find $imp_directory -mmin +30 -type f|tail -1 | xargs ls -l|sed 's/\(.*\ \)\/app.*imp\//\1/'
echo -e "**********************************************************************************************************************"


#check the agreement parameters:
echo;echo -e ">>>the parameters as below:"
#grep -E 'Protocol|RemoteHost|User|RemoteDir|Description|RunMode' ${agr_directory}/*xml
grep -v 'Password' ${agr_directory}/*xml

#check the error log. handle different situations per the ERRORs
echo;echo -e ">>>check the log and find the issue below:"
latest_protlog=`ls -t  ${agr_directory}/prot|head -1`
error_count=`grep 'ERROR:' ${agr_directory}/prot/${latest_protlog}|wc -l|bc`
case $error_count in 
			0)
			echo -e "No error information found in latest prot log. Will check it manually"
			;;
			1)
			grep -C 5 'ERROR:' ${agr_directory}/prot/${latest_protlog} 
			;;
			2)
			grep -C 2 'ERROR:' ${agr_directory}/prot/${latest_protlog}
			;;
			*)
      grep -C 5 'ERROR:' ${agr_directory}/prot/${latest_protlog} | sed -n 1,10p
			;;
esac

#Per the 5th character to privde probable handling way
echo;
#extrac the 5th letter
Region=`echo $1|cut -c 5`;
case $Region in
      A)
      echo -e ">>>Email to contacts and CC Dean"
      ;;
      U)
      echo -e ">>>Email to related contacts"
      ;;
      E)
      echo -e ">>>Email to related contacts"
      ;;
      L)
      echo -e ">>>Sub-call to related team"
      ;;
      *)
      echo -e ">>>Sub-call to HOF - SWORD AM Europe & NMEA"
      ;;
esac



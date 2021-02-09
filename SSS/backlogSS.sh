#!/bin/bash

##########################################################################################################
# This script aims to check backlogs in JMS queue for Scintilla & Shield
# Kindly contact luis.liu@dbschenker.com if you have any concerns
#
#       1/19/2021      -Luis              Updated for sc/sh. Basic script logic updated
#       1/14/2021      -Luis              Script Created
##########################################################################################################

inbound_amount=0
outbound_amount=0


#Check nfs_JMS shiled pending files' PID, 2021.02.08, luis.liu
JMS=/app/sword/shared/mounts/nfsserver/ComServer1/JMS
if [[ "$1" == "sw" ]];then
for i in `ls $JMS`;
do echo -en "$i\t";
find $JMS/$i -type f -name "JMS*arc" -mtime -7 -cmin +30 |wc -l;
grep "BDID" $JMS/$i/b2biprdcom1_shield/SHIELD*/*att 2>/dev/null | cut -d: -f2|cut -d" " -f2|cut -c 3-12| sort| uniq -c;
done ;
echo -en "Total number is: ";
find $JMS/ -type f -name "JMS*arc" -mtime -7 -cmin +30|wc -l;date
exit;
fi

#Default valuable number is 5 minutes
if [[ "$1" == "sc" ]];then dir_name=jmsclients;SS=Scintilla
elif [[ "$1" == "sh" ]];then dir_name=jmsclientsShield; SS=Shield
else echo -e "Usage: backlogSS.sh {sc/sh} {number}(default 5). Kindly input valuable code: sc or sh or sw.";exit;fi
expr $2 + 1 >/dev/null 2>&1; [ $? -ne 0 ] && echo "Usage: backlogSS.sh {sc/sh} {number}(default 5). Kindly input valuable number" && exit
[[ "$2" == "" ]] && time=5 || time=$2

echo -e "\033[41;37m$SS backlogs with files more than $time minutes:\033[0m"

for D in `find /app/sword/schenker/$dir_name/ -maxdepth 1 -type d -name "*_IQ*"`;
do
 BL=`find $D/*.arc -mtime -7 -cmin +"$time" 2>/dev/null |wc -l`
 if [[ $BL != '0' ]];
 then
   echo `basename $D`  $BL
 fi;
 inbound_amount=$(( $inbound_amount+$BL ))
done;

echo -e "\033[41;37mTotal for inbound files:\033[0m\t\t $inbound_amount"

for D in `find /app/sword/schenker/$dir_name/ -maxdepth 1 -type d -name "*_OQ*"`;
do
 BL=`find $D/*.arc -mtime -7 -cmin +"$time" 2>/dev/null |wc -l`
 if [[ $BL != '0' ]];
 then
   echo `basename $D`  $BL
 fi;
 outbound_amount=$(( $outbound_amount+$BL ))
done;

echo -e "\033[41;37mTotal for outbound files:\t\t\033[0m $outbound_amount"

echo -e "\033[41;37mGrand total for all files:\t\t\033[0m $(( $inbound_amount + $outbound_amount ))"



#Check nfs_JMS shield queues, 2021.02.08, luis.liu
JMS=/app/sword/shared/mounts/nfsserver/ComServer1/JMS
if [[ "$1" == "sh" ]];then
echo;echo -e "\033[41;37mChecking nfs_JMS Shield backlogs:\033[0m"
for i in `ls $JMS`;
do echo -e "\033[41;37m$i\033[0m";
for cus_name in `find $JMS/$i -maxdepth 3 -type d -name "SHIELD*"|grep -v "HealthCheck_IQ"|cut -d/ -f11|sed 's/.*PROD.\(.*\)/\1/g'|cut -d. -f1|sort|uniq`
do cou_customer=`find $JMS/$i/b2biprdcom1_shield/SHIELD*$cus_name* -type f -mtime -7 -cmin +"$time"| wc -l`
if [[ "$cou_customer" -ne 0 ]];then
         echo -e "$cus_name\t\t$cou_customer";
        for cus_queue in `find $JMS/$i -maxdepth 3 -type d -name "SHIELD*$cus_name*"`;
                do cou_q_customer=`find $cus_queue -type f -mtime -7 -cmin +"$time" 2>/dev/null |wc -l`;
                if [[ "$cou_q_customer" -ne 0 ]];then
                echo -e `basename $cus_queue|sed 's/.*PROD.\(.*\)/\1/g'` "\t\t$cou_q_customer";fi;
        done;
fi
done;
done;
echo -en "Grand total for all files:"; find $JMS/Parallel*/b2biprdcom1_shield/SHIELD* -type f -mtime -7 -cmin +"$time" 2>/dev/null |wc -l;
date;
exit;
fi

#check nfs_JMS Scintilla queues, 2021.02.08, luis.liu
if [[ "$1" == "sc" ]];then
echo;echo -e "\033[41;37mChecking nfs_JMS Scintilla backlogs:\033[0m"
for i in `ls $JMS`;
do echo -e "\033[41;37m$i\033[0m";
for queue_name in `ls -d $JMS/$i/b2biprdcom1_1/Scintilla*`;do
queue_count=`find $queue_name -type f -mtime -7 -cmin +"$time" 2>/dev/null |wc -l`
if [[ "$queue_count" -ne 0  ]];then
echo -e `basename $queue_name` "\t\t$queue_count";fi
done;
done;
echo -en "Grand total for all files:"; find $JMS/Parallel*/b2biprdcom1_1/Scintilla* -type f -mtime -7 -cmin +"$time" 2>/dev/null |wc -l;
date;
fi;

#!/bin/bash
JMS=/app/sword/shared/mounts/nfsserver/ComServer1/JMS


if [[ "$1" == "q" ]];then
for i in `ls $JMS`;
do echo -e "\033[41;37m$i\033[0m";
for customer in `find $JMS/$i -maxdepth 3 -type d -name "SHIELD*"|grep -v "HealthCheck_IQ"|cut -d/ -f11|sed 's/.*PROD.\(.*\)/\1/g'|cut -d. -f1|sort|uniq`
do echo -e "$customer";
find $JMS/$i -maxdepth 3 -type d -name "SHIELD*$customer*"|cut -d/ -f11|sed 's/.*PROD.\(.*\)/\1/g'
done;
done;
exit;
fi


for i in `ls $JMS`;
do echo -en "$i\t";
find $JMS/$i -type f -name "JMS*arc" -cmin +30 |wc -l;
#find $JMS/$i -maxdepth 3 -type d -name "SHIELD*Service_IQ"|cut -d. -f4-|sort|uniq
grep "BDID" $JMS/$i/b2biprdcom1_shield/SHIELD*/*att 2>/dev/null | cut -d: -f2|cut -d" " -f2|cut -c 3-12| sort| uniq -c;
done ;
echo -en "Total number is: ";
find $JMS/ -type f -name "JMS*arc" -cmin +30|wc -l;date

#!/bin/bash

#Aim to filter all pending files for one remote host
#Author luis.liu@dbschenker.com
#History: updated on 9.13 for all remote host check

#check the $1 value
value_count=`echo $1|wc -m|bc`
[[ "$1" == "" || "$value_count" -le 4 ]] &&  echo -e "Kindly input the correct value you want to check." && exit


echo -e "\033[1;5;37;42m Affected Agrs for $1: \033[0m";echo
for outbound_agr in  `grep -l $1  /app/sword/schenker/comsys/COMS*/agr/*outbound/*xml | sed  's/\(.*outbound\)\/.*xml/\1/g'`;
do countc=`ls $outbound_agr/imp|wc -l`;
        if [ $countc -ne 0 ]
        then    pendingfile_check=`find $outbound_agr/imp -type f -mmin +30|wc -l|bc`
                if [ "$pendingfile_check" -gt 0 ];then
                pendingfile_underimp_count=`ls $outbound_agr/imp|wc -l|bc`
                remotehost=`sed -n '/<RemoteHost>.*<\/RemoteHost>/'p $outbound_agr/*outbound_dump.xml`
                echo -e "\033[37;42m $outbound_agr \033[0m"  "\t" $pendingfile_underimp_count "\t\t" $remotehost
                ls -lrt $outbound_agr/imp|grep -v '^total'|head;echo
                fi
        fi
done

date

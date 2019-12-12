#!/bin/bash

#############################################################################################
#
#
#
#
#    2019.12.8    1h    Added llplist in case to handle the big file easily
#############################################################################################

COM=/app/sword/schenker/comsys
TSUP=/app/sword/schenker/toolslocal/support

if [[ -z "$1" || `echo $1|wc -c|bc` -le 30  ]]
then echo -e "Please input the whole big file name !"
exit 10
fi

if [ -n "$2" ]
then echo -e "The usage should be: llsplit.sh {whole file name} ! No more parameters need."
exit 10
fi

Agr=`ls $1|awk -F. '{print $1}'`
Part1=`ls $1|awk -F. '{print $1"."$2}'`
Part2=`ls $1|awk -F. '{print $3"."$4}'`
Instance=`ls -d /app/sword/schenker/comsys/COMS*/agr/$Agr|cut -d/ -f6`

egrep 'AgrID|RemoteHost|MaxSize' ${COM}/COM*/agr/${Agr}/*l
MaxSize=`grep MaxSize ${COM}/COM*/agr/${Agr}/*l | cut -d">" -f2 | cut -d"<" -f1`
ProSize=`echo $MaxSize*0.8 | bc|cut -d. -f1`

echo -e "Agreement info as below:"
echo $Agr
echo $Maxsize

echo -e "The file will be split with the size $Prosize"


${TSUP}/msplit $1 $ProSize

#/app/sword/schenker/support/luis/backup_script/msplit $1 $ProSize

for i in `find . -type f  -mmin -1 -perm 00664 -exec ls {} \; |cut -d/ -f2`
do      x=`echo $i | awk -F"." '{print $2}'`
        /usr/bin/mv -v $i $COM/${Instance}/comexp_ok/${Part1}_${x}.$Part2
        /usr/bin/mv -v $i /app/sword/schenker/support/luis/TEST/${Part1}_${x}.$Part2
        sleep 10;
done
echo "Wait 5 seconds, then it will check the main log:"
sleep 5;
grep $Part2 $COM/COM*/log/log 

#!/bin/bash

#################################################################################
#Program: Create this script to split the big file easily
#History:	2020.01.10		Released
#Author:	Luis Liu	luis.liu@dbschenker.com
#
#################################################################################


#script works only when luis login
user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit



COM=/app/sword/schenker/comsys
TSUP=/app/sword/schenker/toolslocal/support

#advise to input the correct filename
if [[ -z "$1" || `echo $1|wc -c|bc` -le 30  ]]
then echo -e "Please input the whole big file name !"
exit 10
fi

if [ -n "$2" ]
then echo -e "The usage should be: llsplit.sh {whole file name} ! No more parameters need."
exit 10
fi


#per the input filename, extract the Agr(agreement), Par1/Part2(1st/2nd part of file name when move file to comexp_ok foldr.)
Agr=`ls $1|awk -F. '{print $1}'`
Part1=`ls $1|awk -F. '{print $1"."$2}'`
Part2=`ls $1|cut -d. -f3-`
Instance=`ls -d /app/sword/schenker/comsys/COMS*/agr/$Agr|cut -d/ -f6`

#per the Agr(agreement) to check the reference for one agreement
echo -e ">>>Agreement info as below:"
egrep 'AgrID|RemoteHost|MaxSize' ${COM}/COM*/agr/${Agr}/*l
MaxSize=`grep MaxSize ${COM}/COM*/agr/${Agr}/*l | cut -d">" -f2 | cut -d"<" -f1`
ProSize=`echo $MaxSize*0.8 | bc|cut -d. -f1`

#use msplit to split the file
echo;echo -e ">>>The file will be split with the size $ProSize"

${TSUP}/msplit $1 $ProSize

#move split files to comexp_ok folder each 10 seconds and finally check the main log after 5 seconds
echo;echo -e ">>>Files will be moved to comexp_ok folder every 10 seconds:"
for i in `find . -type f  -mmin -1 -perm 00664 -exec ls {} \; |cut -d/ -f2`
do 	x=`echo $i | awk -F"." '{print $2}'`
	/usr/bin/mv -v $i $COM/${Instance}/comexp_ok/${Part1}_${x}.$Part2
	sleep 10;
done
echo;echo -e ">>>Wait 5 seconds, then it will check the main log:"
sleep 5;
grep _[0-9].$Part2 $COM/COM*/log/log
exit 

#housekeeping the file under error folder
echo;echo -e ">>>housekeeping this big file in error folder:"
Year=`date +"%Y"`
Month=`date +"%m"`
if [ -d /app/sword/schenker/support/error/$Year/$Month ]
    then /bin/mv -v /app/sword/schenker/data/error/$1 /app/sword/schenker/support/error/$Year/$Month
  else  echo;echo -e ">>>Support Error Folder is not existed for this month. Create the folder and housekeeping "
        mkdir -p  /app/sword/schenker/support/error/$Year/$Month
        /bin/mv -v /app/sword/schenker/data/error/$1 /app/sword/schenker/support/error/$Year/$Month
fi

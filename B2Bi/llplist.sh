#!/bin/bash

#############################################################################################
#
#
#
#    2019.12.14   1h    Fixed some bugs and add some description
#    2019.12.8    1h    Added llplist in case to handle the big file easily
#############################################################################################


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
egrep 'AgrID|RemoteHost|MaxSize' ${COM}/COM*/agr/${Agr}/*l
MaxSize=`grep MaxSize ${COM}/COM*/agr/${Agr}/*l | cut -d">" -f2 | cut -d"<" -f1`
ProSize=`echo $MaxSize*0.8 | bc|cut -d. -f1`

echo -e "Agreement info as below:"
echo $Agr
echo $MaxSize

#use msplit to split the file
echo -e "The file will be split with the size $ProSize"

${TSUP}/msplit $1 $ProSize

#move split files to comexp_ok folder each 10 seconds and finally check the main log after 5 seconds

for i in `find . -type f  -mmin -1 -perm 00664 -exec ls {} \; |cut -d/ -f2`
do 	x=`echo $i | awk -F"." '{print $2}'`
	/usr/bin/mv -v $i $COM/${Instance}/comexp_ok/${Part1}_${x}.$Part2
	sleep 10;
done
echo "Wait 5 seconds, then it will check the main log:"
sleep 5;
grep $Part2 $COM/COM*/log/log 




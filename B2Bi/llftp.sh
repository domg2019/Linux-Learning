#!/bin/bash

###########################################################
#Create this script to handle exp files automatically.
#
#
#
#
#
###########################################################

############################################
#test function. test this script in weekend. remove this once the script works fine. 
weekend=`date +%a`
[[ "$weekend" !=  "Sun" && "$weekend" !=  "Sat" ]] && echo "test it when it's weekend" && exit
############################################

COM=/app/sword/schenker/comsys


#advise to input the correct filename
first_dir=`ls /app/sword/shared/ftpserver/customer/*/$1 2>/dev/null|wc -l|bc`
second_dir=`ls /app/sword/shared/ftpserver/customer/*/*/$1 2>/dev/null|wc -l|bc`
third_dir=`ls /app/sword/shared/ftpserver/customer/*/*/*/$1 2>/dev/null|wc -l|bc`

if [[ -z "$1" && ${first_dir} -eq 0  && ${second_dir} -eq 0 && ${third_dir} -eq 0 ]]
then echo -e "Please input the whole inbound file name."
exit 
fi

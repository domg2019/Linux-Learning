#!/bin/bash

#################################################################################
#Program:       Create this script to housekeeping outbound pending files easily
#History:       2020.01.10              Released
#Author:        Luis Liu        luis.liu@dbschenker.com
#Update:  2023.05.20    Update the filename fetch logic -> agreement.count
#################################################################################


#script works only when luis login
user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit

#exist if no input
#[ "$1" == "" ] && echo -e "Usage: ./hk.outbound.sh {whole file name}" && exit
[[ "$1" == "" || `echo "$1"|grep -o "\."|wc -l|bc` -lt 2 ]] && echo -e "Usage: ./hk.outbound.sh {whole file name}" && exit

#make the imptmp default no pending file
#create directory variables per input filename and check if input file name is correct.
filename=`echo $1|cut -d. -f1-2`
imp_value=`ls /app/sword/schenker/comsys/COMS*/agr/*outbound/imp/$filename* 2>/dev/null|wc -l|bc`
impwork_value=`ls /app/sword/schenker/comsys/COMS*/impwork/$filename* 2>/dev/null |wc -l|bc`
##imptmp_value=`ls /app/sword/schenker/comsys/COMS*/archive/imptmp/$filename* >/dev/null 2>&1|wc -l|bc`
##[[ $imp_value -eq 0 && $imptmp_value -eq 0 && $imp_value -eq 0 ]] && echo -e "Kindly input the whole filename." && exit

[[ $imp_value -eq 0 && impwork_value -eq 0 ]] && echo -e "Kindly input the whole filename." && exit


#housekeeping the file per different situations
agreement=`echo $1|cut -d. -f1`
sup_dir=/app/sword/schenker/support


if [ $imp_value -eq 0 ];then
#this means only impwork need to housekeeping
    echo -e ">>>Only pending file in impwork, housekeeping:"
    com_directory=`ls /app/sword/schenker/comsys/COMS*/impwork/$filename*|sed 's/\(.*\)\/impwork.*/\1/'`
                com_instance=`ls /app/sword/schenker/comsys/COMS*/impwork/$filename*|sed 's/.*\(COMS.*\)\/impwork.*/\1/'`
                ls -d ${sup_dir}/${com_instance}/impwork >/dev/null 2>&1
#create the support impwork folder if it's not exist. if it's exist, directly housekeeping.
                [ $? -ne 0] && mkdir -p ${sup_dir}/${com_instance}/impwork
                /bin/mv -v  ${com_directory}/impwork/$filename* ${sup_dir}/${com_instance}/impwork
elif [ $impwork_value -eq 0 ];then
  echo -e ">>>Only pending file in imp, housekeeping:"
  com_directory=`ls /app/sword/schenker/comsys/COMS*/agr/*outbound/imp/$filename*|sed 's/\(.*\)\/agr.*/\1/'`
  com_instance=`ls /app/sword/schenker/comsys/COMS*/agr/*outbound/imp/$filename*|sed 's/.*\(COMS.*\)\/agr.*/\1/'`
        ls -d ${sup_dir}/${com_instance}/${agreement}/imp >/dev/null 2>&1
#create the support imp folder if it's not exist. if it's exist, directly housekeeping.
        [ $? -ne 0 ] && mkdir -p ${sup_dir}/${com_instance}/${agreement}/imp
        /bin/mv -v ${com_directory}/agr/${agreement}/imp/$filename* ${sup_dir}/${com_instance}/${agreement}
else
  echo -e ">>>Housekeeping the imp folder file:"
  com_directory=`ls /app/sword/schenker/comsys/COMS*/agr/*outbound/imp/$filename*|sed 's/\(.*\)\/agr.*/\1/'`
  com_instance=`ls /app/sword/schenker/comsys/COMS*/agr/*outbound/imp/$filename*|sed 's/.*\(COMS.*\)\/agr.*/\1/'`
        ls -d ${sup_dir}/${com_instance}/${agreement}/imp >/dev/null 2>&1
        [ $? -ne 0 ] && mkdir -p ${sup_dir}/${com_instance}/${agreement}/imp
        /bin/mv -v ${com_directory}/agr/${agreement}/imp/$filename* ${sup_dir}/${com_instance}/${agreement}/imp
        echo;echo -e ">>>Housekeeping the impwork folder file:"
        ls -d ${sup_dir}/${com_instance}/impwork >/dev/null 2>&1
  [ $? -ne 0 ] && mkdir -p ${sup_dir}/${com_instance}/impwork
        /bin/mv -v  ${com_directory}/impwork/$filename* ${sup_dir}/${com_instance}/impwork
fi

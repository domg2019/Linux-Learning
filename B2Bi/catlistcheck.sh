#!/bin/bash

#################################################################################
#Program: 	Create this script to housekeeping outbound pending files easily
#History:	2022.04.03		Released
#Update:  2023.12.18  Optimization. amin -> cmin and others
#Author:	Luis Liu	luis.liu@dbschenker.com
#################################################################################

#script works only when luis login
user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
#[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit

COM=/app/sword/schenker/comsys/
CatList=/app/sword/schenker/comsys/COM*/catlist
Sup_dir=/app/sword/schenker/support/

#List all pending catlist files older than 60 mins
CatList_Count=`find /app/sword/schenker/comsys/COM*/catlist -type f -cmin +60 | wc -l`
echo -e "Totally $CatList_Count catlist pending files found as below:"
find /app/sword/schenker/comsys/COM*/catlist -type f -cmin +60
[[ $CatList_Count -eq 0 ]] && echo -e "No pending catlist messages found. exit!" && exit
echo -en "Input 'yes' to continue! Any other input will exit:"
read jud_code
[[ "$jud_code" != "yes" ]] && exit
echo
for File in `find /app/sword/schenker/comsys/COM*/catlist -type f -cmin +60`;
  do File_name=`echo $File|cut -d/ -f8|cut -d. -f1-2`
  Com_instance=`echo $File|cut -d/ -f6`
  echo -e "-------------------------"
  echo -e "$File_name log:"
    grep $File_name $COM/$Com_instance/log/*log 2>/dev/null | grep Successfully
  Exit_code=`echo $?`
  [[ $Exit_code -eq 0 ]] && /bin/mv -v $File $Sup_dir/$Com_instance/catlist || echo -e  "\033[32mThe message may be not successful! Kindly manually check further.\033[0m"
#  main_log_code1=`grep $File_name $COM/$Com_instance/log/*log 2>/dev/null | grep Successfully|wc-l|bc`
#  main_log_code2=`grep $File_name $COM/$Com_instance/log/log* 2>/dev/null | grep Successfully|wc-l|bc`
#  echo -e "-------------------------"
#  [[ $main_log_code1 -eq 0 && $main_log_code2 -eq 0 ]] && /bin/mv -v $File $Sup_dir/$Com_instance/catlist || echo -e  "\033[32mThe message is not successful! Kindly manually check.\033[0m"
  echo -e "-------------------------"
  done

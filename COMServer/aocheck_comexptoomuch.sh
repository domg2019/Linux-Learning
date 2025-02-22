#!/usr/bin/env bash

# Temporarily check the comexp_too_much folder
# luis
# 2023.12.08

ZERO_COUNT=0

for((j=1;j<=2;j++));do
  for i in `ls -d /app/sword/schenker/comsys/COMS*/comexp_too_much`;do
    COMEXPTOOMUCH_COUNT=`ls $i|wc -l`;
    if [[ $COMEXPTOOMUCH_COUNT -gt 0 ]];then
    echo -e "$i\t\t${COMEXPTOOMUCH_COUNT} file(s)";
    echo -en "     oldest file:\t";ls -ltr $i|grep -v ^total|head -1|sed 's#-rw-rw----   1 xib      xib##';
    echo -en "most recent file:\t";ls -lt $i|grep -v ^total|head -1|sed 's#-rw-rw----   1 xib      xib##';
    else echo -e "$i\t\t${COMEXPTOOMUCH_COUNT} file(s)";
    ZERO_COUNT=$(($ZERO_COUNT+1));
    fi
  done
  date
  [[ $ZERO_COUNT -eq 13 ]] && exit
  [[ $j -eq 2 ]] && exit
# Below command
#  echo -e "\033[33m\033[01m\033[05mThere will be second check after 3 seconds to see if oldest files gone.\033[0m"
  echo -e "\033[33m\033[01mThere will be second check after 3 seconds to see if oldest files gone.\033[0m"
  sleep 3;
done



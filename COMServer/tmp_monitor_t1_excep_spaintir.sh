#!/bin/bash

echo -e "This may take few mins, kindly be patient...";echo;

stuckagrs.sh schenker_spaintir| grep /app/sword/schenker/comsys/|awk '{print $2}'|cut -d "/" -f8|sort|uniq > /app/sword/schenker/support/luis/schenker_spaintir.txt;
>/app/sword/schenker/support/luis/monitor_t1_result.txt
listcs -comsys=COMS1_01 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t1_result.txt
listcs -comsys=COMS1_03 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t1_result.txt
listcs -comsys=COMS1_04 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t1_result.txt
listcs -comsys=COMS1_05 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t1_result.txt
listcs -comsys=COMS1_06 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t1_result.txt

echo -e "OUTBOUND except schenker_spaintir:"
for i in `cat /app/sword/schenker/support/luis/monitor_t1_result.txt| grep "/app/.*outbound"|cut -d/ -f8`;
  do grep $i /app/sword/schenker/support/luis/schenker_spaintir.txt 2>/dev/null;
     if [[ `echo $?` == 1 ]]; then echo $i;fi;
done

echo;echo -e "INBOUND:"
grep "/app.*inbound" /app/sword/schenker/support/luis/monitor_t1_result.txt

echo;date

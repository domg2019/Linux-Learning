#!/bin/bash

echo -e "This may take few mins, kindly be patient...";echo;

stuckagrs.sh schenker_cnnew| grep /app/sword/schenker/comsys/|awk '{print $2}'|cut -d "/" -f8|sort|uniq > /app/sword/schenker/support/luis/schenker_stuckagr.txt;
stuckagrs.sh cnpv-ftp.cn.signintra.com| grep /app/sword/schenker/comsys/|awk '{print $2}'|cut -d "/" -f8|sort|uniq > /app/sword/schenker/support/luis/schenker_stuckagr.txt;
>/app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS1_02 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS1_07 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS1_L1 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS1_L2 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS1_L3 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS2_01 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMS2_L1 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt
listcs -comsys=COMSL_99 -fileagemin=30 >> /app/sword/schenker/support/luis/monitor_t2_result.txt

echo -e "OUTBOUND except schenker_cnnew & cnpv-ftp.cn.signintra.com:"
for i in `cat /app/sword/schenker/support/luis/monitor_t2_result.txt| grep "/app/.*outbound"|cut -d/ -f8`;
  do grep $i /app/sword/schenker/support/luis/schenker_stuckagr.txt >/dev/null;
     if [[ `echo $?` == 1 ]]; then echo $i;fi;
done

echo;echo -e "INBOUND:"
grep "/app.*inbound" /app/sword/schenker/support/luis/monitor_t2_result.txt

echo;date

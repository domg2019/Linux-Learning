#!/bin/bash

###########################################################
#Create this script to handle exp files automatically.
#2020.01.05
#
#
#
#
###########################################################

############################################
#test function. test this script in weekend. remove this once the script works fine. 
#weekend=`date +%a`
#[[ "$weekend" !=  "Sun" && "$weekend" !=  "Sat" ]] && echo "test it when it's weekend" && exit
############################################

#script works only when luis login
user=`who|sed -n '/luisliu1/p'|awk '{print $1}'|uniq`
[ "$user" != "luisliu1" ] && echo -e "script only works when luis login. contact luis in case of any concern." && exit


COM=/app/sword/schenker/comsys


#advise to input the correct filename
ls ${COM}/COMS*/agr/*inbound/exp/$1 &>/dev/null
if [[ -z "$1" || $? -ne 0  ]]
then echo -e "Please input the whole inbound file name."
exit 
fi

#extract the necessary variables
agreement=`echo $1|cut -d. -f1`
filename=`echo $1|cut -d. -f2-`
error_sup=/app/sword/schenker/support/error
exp_directory=`ls ${COM}/COMS*/agr/*inbound/exp/$1|cut -d. -f1|sed 's/\(.*exp\).*/\1/'`
com_direcroty=`ls ${COM}/COMS*/agr/*inbound/exp/$1|cut -d. -f1|sed 's/\(.*\)\/agr.*/\1/'`
sup_comsys=`echo com_direcroty|sed 's/comsys/support/'`
archive_date=`date +%Y/%m`

#display the pending file:
echo -e ">>>there is one inbound file received:"
ls -l ${COM}/COMS*/agr/*inbound/exp/$1


#check log to judge if the file is already successfully transferred earlier
grep $filename ${com_direcroty}/log/log | grep 'Renaming file' &>/dev/null
if [ $? -eq 0 ]
	then echo;echo -e ">>>the file is already transferred successfully earlier as below:" 
		 grep $filename ${com_direcroty}/log/log| tail -10
		 echo;echo -e ">>>housekeeping in the shell:"
		 ls -d ${sup_comsys}/${agreement} &>/dev/null
		 if [ $? -eq 0 ];then
#		 /usr/bin/mv -v $exp_directory/$1 ${sup_comsys}/${agreement}
echo -e "test success. move file to housekeeping"
#		 else /usr/bin/mv -v $exp_directory/$1 ${error_sup}/${archive_date=}
else echo -e "test success. move file to housekeeping"
		 exit
		 fi
	else 	 	echo;echo -e ">>>check the archive folder and the transfer log but there is no record. Also no records in SWING."
				echo;echo -e ">>>the file is not transfered successfully due to: "
				latest_protlog=`ls -t ${com_direcroty}/agr/${agreement}/prot|head -1`
				grep -C3 ':ERROR:' ${com_direcroty}/agr/${agreement}/prot/${latest_protlog}
				echo;echo -e ">>>Move to next step:"
				/usr/bin/mv -v $exp_directory/$1 $com_direcroty/comexp_ok/
				echo;echo -e ">>>Sleep 15 seconds to check the log information..."
				sleep 15
				logfilename=`echo $filename|cut -d. -f2-`
				grep $logfilename ${com_direcroty}/log/log | tail -10
fi

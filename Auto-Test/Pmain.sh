#!/bin/bash

supportFolder="/app/sword/schenker/support"
houseKeepPath=${supportFolder}/error/$(date "+%Y/%m/")
errorFodler="/app/sword/schenker/data/error"
luis_folder_dir="/app/sword/schenker/support/luis"

function ref()
{
    for file in $(ls ${errorFodler}/*$1*.att | grep -v "MassFilter")
    do
        basename ${file};
        transaction=$(grep -A1 -E '^TransactionAttribute$' ${file} | grep -v "^TransactionAttribute$" | head -1);
        echo "Date/Time : $(echo ${transaction} | grep -Eo "[0-9]{4}-[a-zA-Z]{3}-[0-9]{2} [0-9:]{8}") CET";
        echo "TRID : $(grep -A1 -E '^TRID$' ${file} | sed -n '2p')";
        BDIDRefValues=$(grep -A1 -E '^BDIDRefValues$' ${file} | grep -v "^BDIDRefValues$" | head -1);
        if [[ ${BDIDRefValues} != '' ]];then
            echo ${BDIDRefValues:0:99} | awk -F\" '{print "BDID : "$2}';
            echo $BDIDRefValues | grep -Eo "\{[^{}]+\}" | awk -F\" '{print $2" : "$4}'
        fi
        echo "TransactionAttribute : ";
        echo "${transaction}";
        echo -en "\n";
    done
}

function hk()
{
if [[ $1 != '' && $(echo $1 | grep -Eo [A-Z_0-9]{10}) == $1 ]]; then
    cd ${errorFodler};
    echo;
    processID=$1;
    hkTmpFile="/tmp/hk_${processID}_$(date "+%Y%m%d%H%M%S").tmp";
    find /tmp/ -mtime +1 -name "hk_*.tmp" -exec /bin/rm {} \; 2>/dev/null;
    if [[ $(ls /tmp/hk_${processID}_*.tmp 2>/dev/null | wc -l | bc) != 0 ]];then
        echo "TMP file found for process ${processID} in /tmp as below";
        ls /tmp/hk_${processID}_*.tmp;
        echo "Possible root cause: Someone is running this command right now.";
        echo "Please check with your colleagues.";
        echo "Only remove the files if no one else is running hk (please check with ps -efa | grep hk | grep ${processID} | grep -v grep) and try again.";
    else
        ls | grep -v "MassFilter" | grep "${processID}.*.att" | sed 's/.att$//g' > ${hkTmpFile};
        echo -n ">>>The number of ${processID} error file(s) is: ";
        wc -l ${hkTmpFile} | awk '{print $1}';
        for file in $(cat ${hkTmpFile})
        do
            ls -l ${file}*;
        done
        echo -e "\n>>>File info:";
        for file in $(cat ${hkTmpFile})
        do
            ref ${file};
        done
        echo ">>>Moving file to housekeeping folder:";
        for file in $(cat ${hkTmpFile})
        do
            /bin/mv -v ${file}* ${houseKeepPath};
        done
        /usr/bin/rm ${hkTmpFile};
    fi
else
    echo "Please input a valid processID as parameter.";
fi
}

current_date=`date "+%Y%m%d"`
# create folder for current shift per the date your shift starts. Not for US shift as it crosses two dates
if [ ! -d ${luis_folder_dir}/${current_date} ]; then mkdir -p ${luis_folder_dir}/${current_date};fi

cd ${errorFodler};
/app/sword/schenker/toolslocal/support/clean_up -v;
current_error_pids=`ls *att| grep -v "MassFilter" | cut -d. -f1 | sort | uniq`
for single_pid in ${current_error_pids};
  do if [ `ls -d ${luis_folder_dir}/${current_date}/${single_pid} 2>/dev/null |wc -l|bc` -eq 0 ];
      then mkdir  -p ${luis_folder_dir}/${current_date}/${single_pid};
cat >> ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt << EOF
Dear Team,
Kindly route TO:SWORD:AO:

EOF
        hk ${single_pid} | tee -a ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt
        cat  ${luis_folder_dir}/email_signature >>  ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt
#        /bin/mail -s PME_${single_pid} support.sword-csd@dbschenker.com < ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt
#        /bin/mail -s PME_${single_pid} luis.liu@dbschenker.com < ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt
        else
        hk ${single_pid} | tee -a ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt
        fi
done


# ToDo



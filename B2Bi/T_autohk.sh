#!/bin/bash

houseKeepPath='/app/sword/schenker/support/luis/hkpath'
luis_error_folder="/app/sword/schenker/support/luis/error"
luis_folder_dir="/app/sword/schenker/support/luis"
current_date=`date "+%Y%m%d"`
# create folder for current shift per the date your shift starts. Not for US shift as it crosses two dates
if [ ! -d ${luis_folder_dir}/${current_date} ]; then mkdir -p ${luis_folder_dir}/${current_date};fi

function ref()
{
    for file in $(ls ${luis_error_folder}/*$1*.att 2>/dev/null | grep -v "MassFilter")
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
    cd ${luis_error_folder};
    # no clean_up in test environment
#    /app/sword/schenker/toolslocal/support/clean_up -v;
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

function test_ref()
{
    for file in $(ls *$1*.att 2>/dev/null | grep -v "MassFilter")
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



function test_hk()
{
if [[ $1 != '' && $(echo $1 | grep -Eo [A-Z_0-9]{10}) == $1 ]]; then
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
            test_ref ${file};
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

function checkError()
{
    fileCount=$(ls "${luis_error_folder}"  2>/dev/null | grep -c "\.att$" | bc);
    [[ "${fileCount}" != "0" ]] && echo -en "\a";
    echo -n "Massfilter : ";
    ls "${luis_error_folder}" 2>/dev/null| fgrep "MassFilter" | grep -c "\.att$";
    ls "${luis_error_folder}" 2>/dev/null| fgrep "MassFilter" | grep "\.att$" | cut -d\. -f2 | sort | uniq -c | while read line
    do
    echo "    ${line}";
    done
    echo -n "Error : ";
    ls "${luis_error_folder}" 2>/dev/null| fgrep -v "MassFilter" | grep -c "\.att$";
    ls "${luis_error_folder}" 2>/dev/null| fgrep -v "MassFilter" | grep "\.att$" | cut -d\. -f1 | sort | uniq -c | while read line
    do
        echo "    ${line}";
        processID=$(echo "${line}" | awk '{print $2}')
        ls -l | fgrep "${processID}." | while read subLine
        do
            echo "        ${subLine}";
        done
    done
}



function Beep(){
        if [[ $beep == b ]];
                then  if [[ $(ls ${luis_error_folder} 2>/dev/null | wc -l | bc) != 0 ]];
                                        then for i in $(seq 6);
                                                        do echo -en "\a";
                                                        usleep 600000;
                                                 done;
                          fi
        fi
}


function auto_housekeeping(){
# handle massfilter errors 1stly
[[ `ls ${luis_error_folder}/MassFilter*att 2>/dev/null | wc -l|bc ` -gt 0 ]] && [[ ! -d  ${luis_folder_dir}/${current_date}/MassFilter ]] && mkdir -p ${luis_folder_dir}/${current_date}/MassFilter

if [ `ls ${luis_error_folder}/MassFilter*att 2>/dev/null | wc -l|bc ` -gt 0 ];
  then   massfilter_pids=`ls ${luis_error_folder}/MassFilter*att 2>/dev/null | cut -d. -f2 | sort | uniq`
           for massfilter_pid in ${massfilter_pids};
               do
                 if [ `ls -d ${luis_folder_dir}/${current_date}/MassFilter/${massfilter_pid} 2>/dev/null |wc -l|bc` -eq 0 ];
                    then mkdir -p ${luis_folder_dir}/${current_date}/MassFilter/${massfilter_pid};
                    fi
                 if [ `ls ${luis_error_folder}/MassFilter.${massfilter_pid}*att 2>/dev/null | wc -l|bc` -lt 100 ];
                 then echo "run massfilter"
                 else echo "massfilter more than 100"
                 fi
           done
fi

# handle SYSTXERROR
SYSTXERROR_count=`ls ${luis_error_folder}/SYSTXERROR*att 2>/dev/null | wc -l|bc`
[[ ${SYSTXERROR_count} -gt 0 ]] && [[ ! -d  ${luis_folder_dir}/${current_date}/SYSTXERROR ]] && mkdir -p ${luis_folder_dir}/${current_date}/SYSTXERROR
if [ ${SYSTXERROR_count} -gt 0 ];
then  SYSTXERROR_refs=$(for i in `ls ${luis_error_folder}/SYSTXERROR*att 2>/dev/null`;do grep -A 1 "^TransactionAttribute" $i | sed -n 2p | cut -d, -f21 | cut -d"\"" -f2;done |sort | uniq)
      echo -e "~~~~~~~~~~~~~~~~~~~";echo ${SYSTXERROR_refs}
      for SYSTXERROR_ref in ${SYSTXERROR_refs};
      do SYSTXERROR_pid=`echo -e ${SYSTXERROR_ref}|sed -e s/"\W"//g`;
      if [ `ls -d  ${luis_folder_dir}/${current_date}/SYSTXERROR/${SYSTXERROR_pid} 2>/dev/null |wc -l|bc` -eq 0 ];
      then touch ${luis_folder_dir}/${current_date}/SYSTXERROR/${SYSTXERROR_pid}.txt
      SYSTXERROR_files=`grep -wol "${SYSTXERROR_ref}" SYSTXERROR*att 2>/dev/null |cut -d. -f1-4`
      for SYSTXERROR_file in ${SYSTXERROR_files};
      do  /bin/mv ${SYSTXERROR_file}.* ${luis_folder_dir}/${current_date}/SYSTXERROR/
      done
      cd ${luis_folder_dir}/${current_date}/SYSTXERROR/;
      test_hk SYSTXERROR | tee -a ${luis_folder_dir}/${current_date}/SYSTXERROR/${SYSTXERROR_pid}.txt
      cd ${luis_error_folder}
      else
      SYSTXERROR_files=`grep -wol "${SYSTXERROR_ref}" SYSTXERROR*att 2>/dev/null |cut -d. -f1-4`
      for SYSTXERROR_file in ${SYSTXERROR_files};
      do  /bin/mv ${SYSTXERROR_file}.* ${luis_folder_dir}/${current_date}/SYSTXERROR/
      done
      cd ${luis_folder_dir}/${current_date}/SYSTXERROR/;
      test_hk SYSTXERROR | tee -a ${luis_folder_dir}/${current_date}/SYSTXERROR/${SYSTXERROR_pid}.txt
      cd ${luis_error_folder}
      fi
      done
fi


# Only handle PIDs while not massfilter or SYSTXERROR
current_error_pids=`ls *att 2>/dev/null | grep -v "MassFilter" | grep -v "SYSTXERROR" | cut -d. -f1 | sort | uniq`
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
        echo -e "";
        else
        hk ${single_pid} | tee -a ${luis_folder_dir}/${current_date}/${single_pid}/${single_pid}.txt
        echo -e "";
        fi
done

# display current shift's errors
clear
echo -e "\033[41;37mLatest Auto-HK Statistics: \033[0m"
echo -e "PID:     \t\tCount:";
for error_pid in `ls ${luis_folder_dir}/${current_date}/`;
  do if [[ ${error_pid} != "MassFilter"  && ${error_pid} != "SYSTXERROR" ]];then
     error_hk_times=`grep "housekeeping" ${luis_folder_dir}/${current_date}/${error_pid}/${error_pid}.txt | wc -l|bc`
     echo -e "${error_pid} \t\t ${error_hk_times}"
     elif [ ${error_pid} == "SYSTXERROR" ];
     then
      echo -e "Below calculation is for SYSTXERROR:"
      for SYSTXERROR_att in `ls ${luis_folder_dir}/${current_date}/SYSTXERROR/| cut -d. -f1`;
      do error_hk_times=`grep "housekeeping" ${luis_folder_dir}/${current_date}/SYSTXERROR/*.txt | wc -l|bc`
      echo -e "${SYSTXERROR_att} \t\t ${error_hk_times}"
      done
     fi
done
}

clear
date
cd ${luis_folder_dir}/error;

# keep monitoring error folder
gap=$(echo $1 | bc);
    beep=$(echo $2);
command='';
if [[ "${gap}" == "" ]]; then
    auto_housekeeping;
    echo -e "";echo -e "\033[41;37mCurrent Error Folder: \033[0m"
    checkError;
else
    while true
    do
        if [[ "${command}" != "" ]]; then
            ${command};
            command='';
            echo -e "\nCommand ${command} has been executed, please press Enter to continue.";
            read dummy;
        else
            clear;
            date;
            auto_housekeeping;
            echo -e "";echo -e "\033[41;37mCurrent Error Folder: \033[0m"
            checkError;
            Beep;
            echo -e "Next check will be executed ${gap} seconds later.\nPress Enter to check again immediately.\nInput any command to run immediately.";
            read -t "${gap}" command;
        fi
    done
fi
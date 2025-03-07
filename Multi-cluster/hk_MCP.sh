#!/bin/bash

##############################################################################
# just tmp script under luis.
# function: aim to list specific node for errors to simplfy the task handle
# Name: Luis Liu
# Update      2025.03.05  Optimize the grep -wl logic.
# creation date:    2023.02.16
##############################################################################

errorFolder="/app/sword/schenker/data/error";
supportFolder="/app/sword/schenker/support";
houseKeepPath=${supportFolder}/error/$(date "+%Y/%m/");

function ref()
{
        for file in $(ls ${errorFolder}/*$1*.att | grep -v "MassFilter")
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
                echo -e "${transaction}\n";
        done
}

function hk()
{
        if [[ $1 != '' && $(echo $1 | grep -Eo [A-Z_0-9]{10}) == $1 ]]; then
                processID=$1;
                cd ${errorFolder};
                /app/sword/schenker/toolslocal/support/clean_up -v;
                echo -e "\e[42mclean_up command completed, proceeding...\e[0m"
                hkTmpFile="/tmp/hk_${processID}_$(date "+%Y%m%d%H%M%S").tmp";
                find /tmp/ -mtime +1 -name "hk_*.tmp" -exec /bin/rm {} \; 2>/dev/null;
                if [[ $(ls /tmp/hk_${processID}_*.tmp 2>/dev/null | wc -l | bc) != 0 ]];then
                        echo "TMP file found for process ${processID} in /tmp as below";
                        ls /tmp/hk_${processID}_*.tmp;
                        echo "Possible root cause: Someone is running this command right now.";
                        echo "Please check with your colleagues.";
                        echo "Only remove the files if no one else is running hk (please check with ps -efa | grep hk | grep ${processID} | grep -v grep) and try again.";
                        exit;
                fi
                if [[ "$1" == "SYSTXERROR" ]]; then
                        [[ "$2" == "" ]] && echo "Please input the SYSTXERROR ref. Usage: hk + SYSTXERROR + {SYSTXERROR ref}" &&  exit
                        systxerror_files=$(ls ${errorFolder}/SYSTXERROR*att 2>/dev/null)
                        [[ -z "$systxerror_files" ]] && echo "There are no SYSTXERRORs for the reference anymore! Files might be clean_up already!" &&  exit
                        [[ -n "$systxerror_files" ]] && grep -wl "$2" $(ls ${errorFolder}/SYSTXERROR*att 2>/dev/null) |cut -d"/" -f7  | sed 's/.att$//g' > ${hkTmpFile};
                else ls | grep -v "MassFilter" | grep "${processID}.*.att" | sed 's/.att$//g' > ${hkTmpFile};
                fi
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
        else
                echo "Please input a valid processID as parameter.";
        fi
}


hk "$@";
#!/bin/bash

#######################################
# just tmp script under luis
#######################################

errorFolder="/app/sword/schenker/data/error";

function Beep()
{
        if [[ $beep == b ]];
                then  if [[ $(ls /app/sword/schenker/data/error | wc -l | bc) != 0 ]];
                                        then for i in $(seq 6);
                                                        do echo -en "\a";
                                                        sleep 0.6;
                                                 done;
                          fi
        fi
}

function checkError()
{
    fileCount=$(ls "${errorFolder}" | grep -c "\.att$" | bc);
    [[ "${fileCount}" != "0" ]] && echo -en "\a";
    echo -n "Massfilter : ";
    ls "${errorFolder}" | fgrep "MassFilter" | grep -c "\.att$";
    ls "${errorFolder}" | fgrep "MassFilter" | grep "\.att$" | cut -d\. -f2 | sort | uniq -c | while read line
    do
        echo -en "    ${line}\t\t";
        massfilter_pid=`echo "${line}"|cut -d" " -f2`
        oldest_att_file=`ls -tr ${errorFolder}/MassFilter.${massfilter_pid}*att 2>/dev/null |grep -v "^total"| head -1`
#        grep -A 1 "TRID" "$oldest_att_file" 2>/dev/null|sed -n "2p"|cut -c 1,2
        grep "BDIDRefValues" "$oldest_att_file" &>/dev/null
        if [[ `echo $?` == 0 ]];
          then grep -A1 "BDIDPositions_IN" "$oldest_att_file"|sed -n "2p"|cut -d"\"" -f2|cut -c 1,2;
        else
# one bug deteced for one message which contains refer ID: InitialTRID.
#          grep -A 1 "TRID" "$oldest_att_file"|sed -n "2p"|cut -c 1,2
          grep -A 1 "TRID" "$oldest_att_file"|tail -1|cut -c 1,2
        fi
    done
    echo -n "Error : ";
    ls "${errorFolder}" | fgrep -v "MassFilter" | fgrep -v "SYSTXERROR" | grep -c "\.att$";
    ls "${errorFolder}" | fgrep -v "MassFilter" | fgrep -v "SYSTXERROR" | grep "\.att$" | cut -d\. -f1 | sort | uniq -c | while read line
    do
        echo -en "    ${line}\t\t";
        processID=$(echo "${line}" | awk '{print $2}')
        oldest_att_file=`ls -tr ${errorFolder}/${processID}*att 2>/dev/null |grep -v "^total"| head -1`
        grep "BDIDRefValues" "$oldest_att_file" &>/dev/null
        if [[ `echo $?` == 0 ]];
          then grep -A1 "BDIDPositions_IN" "$oldest_att_file"|sed -n "2p"|cut -d"\"" -f2|cut -c 1,2;
        else
# one bug deteced for one message which contains refer ID: InitialTRID.
#          grep -A 1 "TRID" "$oldest_att_file"|sed -n "2p"|cut -c 1,2
          grep -A 1 "TRID" "$oldest_att_file"|tail -1|cut -c 1,2
        fi
        #below 5 lines aim to show details under current directory
        #processID=$(echo "${line}" | awk '{print $2}')
        ls -l | fgrep "${processID}." | while read subLine
        do
            echo "        ${subLine}";
        done
    done
    SYSTXERROR_count=`ls ${errorFolder}/SYSTXERROR*att 2>/dev/null | wc -l|bc`
    if [[ ${SYSTXERROR_count} -gt 0 ]]; then echo -n "SYSTXERROR Error : ";
    ls "${errorFolder}" | fgrep "SYSTXERROR" | grep -c "\.att$";
#    for i in `ls ${errorFolder}/SYSTXERROR*att 2>/dev/null`;do grep -A 1 "^TransactionAttribute" $i | sed -n 2p | cut -d, -f21 | cut -d"\"" -f2;done |sort | uniq -c | while read line
    for i in `ls ${errorFolder}/SYSTXERROR*att 2>/dev/null`;do grep -A 1 "^TransactionAttribute" $i | sed -n 2p |awk -F"\"ERROR\"" '{print $2}'|cut -d, -f12| cut -d"\"" -f2;done |sort | uniq -c | while read line
    do
        echo -en "    ${line}\t\t";
        key_refs=$(echo "${line}" | awk '{print $2}')
        oldest_att_file=$(grep -l ${key_refs} $(ls -1rt /app/sword/schenker/data/error/SYSTXERROR*att) |head -1)
#        echo $oldest_att_file
        grep "BDIDRefValues" "$oldest_att_file" &>/dev/null
        if [[ `echo $?` == 0 ]];
          then grep -A1 "BDIDPositions_IN" "$oldest_att_file"|sed -n "2p"|cut -d"\"" -f2|cut -c 1,2;
        else
# one bug deteced for one message which contains refer ID: InitialTRID.
#          grep -A 1 "TRID" "$oldest_att_file"|sed -n "2p"|cut -c 1,2
          grep -A 1 "TRID" "$oldest_att_file"|tail -1|cut -c 1,2
        fi
     done
     fi
}

function monitor()
{
    gap=$(echo $1 | bc);
        beep=$(echo $2);
    command='';
    if [[ "${gap}" == "" ]]; then
        checkError;
    elif [[ "${gap}" -gt 60 || "${gap}"  -lt 5 ]]
        then echo -e "Please input the monitor time value between 5-60 (min)"
    else
       for((count=1;count<=$((480/${gap}));count++))
        do
            if [[ "${command}" != "" ]]; then
                ${command};
                command='';
                echo -e "\nCommand ${command} has been executed, please press Enter to continue.";
                read dummy;
            else
                clear;
                date;
                checkError;
                                Beep;
                echo -e "Next check will be executed ${gap} minutes later.\nPress Enter to check again immediately.\nInput any command to run immediately.";
                read -t "$((${gap}*60))" command;
                sleep 1;
            fi
        done
    fi
}


monitor "$@";
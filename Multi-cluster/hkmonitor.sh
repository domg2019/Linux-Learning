#!/bin/bash

#####################################################################################################################
# Optimized monitor Script for updating which node it belongs according to oldest failure file. optmonitor is only for
# for Luis while monitor is for team
# Name:     Luis Liu
#
# History:
# 06.26.2024      Update. Opt ignore mark
# 01.20.2024      Update. Add new feature to auto hk known issue
# 12.03.2023      Update. Add the feature to compare arc and att filecount
# 10.23.2023      Update. Fix one bug that BDIDPositions_IN in useless
# 04.19.2023      Update. Add one more variable $3 for multi nodes related to Beep function
# 02.27.2023      Update. Replace "sed -n 2p" by "tail -1" as there is specific situation that more than 2 lines
# 02.23.2023      Update. Replace "grep -l" by "grep -wl" as KeyWords(refs) could be on other places
# 02.05.2023      Created
#####################################################################################################################


errorFolder="/app/sword/schenker/data/error";
supportFolder="/app/sword/schenker/support";
houseKeepPath=${supportFolder}/error/$(date "+%Y/%m/");
#pre-check to hk PIDs could be ignored currently. You can add pid in this ignore_dict var but except SYSTXERROR
ignore_dict="LUISTESPID
ABS_UPCAOS:20240621
ADIDAICSO1
AFH_TORDER:20240703Y
ALDIAPOEML:20240627
ALDIUCPO2S
ASCEULESLA
BLYOUMDMRS:20240705
BOEHTSGISH
BOEIE315CE
BOSCWSPLIS
BP__MCESAN:20240627Y
CNH_S1LOAD
CTTSWSTIXM
DANFWASOXM
DELLABLU06:20240702Y
DELLAEMCCE:20240705
DELLECE315:20240620
EKORTSC2PO:20240620
EUCAEALLIN:20240703
FJFMT2FUOC
HPGLEESISG
INSPT_POIN:20240704
MERCLORDRS:20240705Y
MESSSH01FL:20240627
MOTOAJPINV:20240613
PEPCTCPODM:20240609
PRGBEINACK
ROCKUINVOU
SCDEL0086M
SCDEL0141T
SCDEL01A87:20240718Y
SCDEL02A67:20240612
SCDEL0408A:20240612
SCDELFFFF1:20240607
SCDELKAES1:20240611
SCXXTRCUSD:20240704
SCZAETDDED
STARSINVAT
STARSRO2IN
SCFRWPICED:20240620
SCEULESLAN:20240626Y
UNLVMPK2XM";


#verify if there are duplicate PIDs input in the variable ignore_dict. you can use this command to find which PID is duplicate(remember to replace correct script name)----for i in `grep ignore_dict test.sh |head -1|cut -d"\"" -f2`;do echo $i;done|sort | uniq -c
[[ $(for i in `echo $ignore_dict`;do echo $i;done| sort | uniq -c| awk '{print $1}'|uniq|wc -l|bc) -gt 1 ]] && echo "Duplicate elements in ignore_dict detected!" && exit

#check if there is single arc file pending there
#if [[ `ps -ef| grep -v grep | grep remafi|wc -l|bc` -eq 0 || ]];
#  then  ARCCOUNT=`ls ${errorFolder}/*arc 2>/dev/null|wc -l|bc`;
#        ATTCOUNT=`ls ${errorFolder}/*att 2>/dev/null|wc -l|bc`;
#        if [[ ${ARCCOUNT} -ne ${ATTCOUNT} ]];
#        then echo -e "\033[41;37mKindly note arc and att filecount doesn't match. Manually list error folder PLZ!!!\033[0m";
#        exit;
#        fi
#fi

#Massfilter_ARCCOUNT=`ls ${errorFolder}/MassFilter*arc 2>/dev/null|wc -l|bc`
#Massfilter_ATTCOUNT=`ls ${errorFolder}/MassFilter*att 2>/dev/null|wc -l|bc`
if [[ `ls ${errorFolder}/MassFilter*att 2>/dev/null|wc -l|bc` -lt 3 ]];then
#ARCCOUNT=`ls ${errorFolder}/*arc 2>/dev/null|grep -v MassFilter|wc -l|bc`
#ATTCOUNT=`ls ${errorFolder}/*att 2>/dev/null|grep -v MassFilter|wc -l|bc`
ARCCOUNT=`ls ${errorFolder}/*arc 2>/dev/null|wc -l|bc`;
ATTCOUNT=`ls ${errorFolder}/*att 2>/dev/null|wc -l|bc`;
if [[ ${ARCCOUNT} -ne ${ATTCOUNT} ]];
then echo -e "\033[41;37mKindly note arc and att filecount doesn't match. Manually list error folder PLZ!!!\033[0m";
exit;
fi
fi


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
#    [[ "${fileCount}" != "0" ]] && echo -en "\a";
echo -n "Massfilter : ";
ls "${errorFolder}" | fgrep "MassFilter" | grep -c "\.att$";
ls "${errorFolder}" | fgrep "MassFilter" | grep "\.att$" | cut -d\. -f2 | sort | uniq -c | while read line
do
    echo -en "    ${line}\t\t";
    massfilter_pid=`echo "${line}"|cut -d" " -f2`
    oldest_att_file=`ls -tr ${errorFolder}/MassFilter.${massfilter_pid}*att 2>/dev/null |grep -v "^total"| head -1`
#        grep -A 1 "^TRID" "$oldest_att_file" 2>/dev/null|tail -1|cut -c 1,2
    grep "BDIDRefValues" "$oldest_att_file" &>/dev/null
    if [[ `echo $?` == 0 ]];
# then grep -A1 "BDIDPositions_IN" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2;
# update below reference from BDIDPositions_IN to BDIDRefValues
      then mcp_node=`grep -A1 "BDIDRefValues" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2`;
          echo $mcp_node;
# one bug deteced for one message which contains refer ID: InitialTRID.
#          grep -A 1 "^TRID" "$oldest_att_file"|tail -1|cut -c 1,2
      else
        grep -A 1 "^TRID" "$oldest_att_file"|tail -1|cut -c 1,2
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
# one situation that there is no TRID
    then
          if [[ `grep -A 1 "^TRID" "$oldest_att_file"|tail -1|cut -c 1,2` == "" ]];
          then grep -A1 "BDIDRefValues" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2

#          then grep -A1 "BDIDPositions_IN" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2;
          else mcp_node=`grep -A1 "BDIDPositions_IN" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2`;
              echo $mcp_node;
          fi
# one bug deteced for one message which contains refer ID: InitialTRID.
#          grep -A 1 "^TRID" "$oldest_att_file"|tail -1|cut -c 1,2
      else
        grep -A 1 "^TRID" "$oldest_att_file"|tail -1|cut -c 1,2
      fi
    #below 4 lines aim to show details under current directory
    #processID=$(echo "${line}" | awk '{print $2}')
#        current_user=`who| head -1|cut -d" " -f1`
#        if [[ ${current_user} != "tomyli01" ]]; then
    ls -l | fgrep "${processID}." | while read subLine
    do
        echo "        ${subLine}";
    done
#        fi
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
#          then grep -A1 "BDIDPositions_IN" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2;
       then mcp_node=`grep -A1 "BDIDPositions_IN" "$oldest_att_file"|tail -1|cut -d"\"" -f2|cut -c 1,2`;
                                         if [[ "$mcp_node" == "E1" ]];then echo 3A;
                                                   else  echo $mcp_node;
                                                                       fi
# one bug deteced for one message which contains refer ID: InitialTRID.
#          grep -A 1 "^TRID" "$oldest_att_file"|tail -1|cut -c 1,2
      else
                    mcp_node=`grep -A 1 "TRID" "$oldest_att_file"|tail -1|cut -c 1,2`;
                        if [[ "$mcp_node" == "E1" ]];then echo 3A;
                                            else  echo $mcp_node;
                                                                fi
      fi
#this file name is for SYSTXERROR refs. The filename will be stored in folder:
    filename=$(echo ${key_refs}|tr -cd '[:alnum:]')
#this 'if' is to auto-hk systxerror refer. Comment this as no node judgement
#    if [[ "${key_refs}" ==  "t3s://slmsg.dc.signintra.com:7303" || "${key_refs}" ==  "QM.SWORD" || "${key_refs}" == "SAP" ]];
#      then touch ${supportFolder}/luis/SYSTXERROR/${filename}
#      for syst_file in `grep -l "${key_refs}" ${errorFolder}/SYSTXERROR*att| cut -d"/" -f7|cut -d. -f1-4`;
#      do /bin/mv -v ${errorFolder}/${syst_file}* ${houseKeepPath} > ${supportFolder}/luis/TMP/syst_hk_record.txt;
#      done
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
            checkError | tee /tmp/check_error_result.tmp
            mcp_nodes=`cat /tmp/check_error_result.tmp|grep '^ '|awk '{print $3}'|sort|uniq`
            if [[ $3 == "" ]];
            then Beep;
            else
              [[ $((`echo $3|wc -c`%2)) == 0 ]] && echo -e "\033[41;37mPlease input node name correctlly. Correct eg: 3a3b or 3a2b\033[0m" && exit
              loop_count=0
              for node in `cat /tmp/check_error_result.tmp|grep '^ '|awk '{print $3}'|sort|uniq`;
#                  do  loop_count=$((`echo "$3" | grep -i $node|wc -l`+$loop_count))
              do if [[ `echo "$3" | grep -i $node|wc -l|bc` -gt 0 ]];
                 then loop_count=$((1+$loop_count));
                 for Node_Pid in `sed -n '/Error/,/SYSTXERROR/p' /tmp/check_error_result.tmp | egrep -v "SYSTXERROR|Error"|grep -i $node |awk '{print $2}'`;do
                   if [[ `echo ${ignore_dict}| grep ${Node_Pid}|wc -l|bc` -gt 0 ]];then
                      Node_Pid_date=`echo $ignore_dict| grep -oE ${Node_Pid}':?[0-9]*[A-Z]?'`
                      echo -e "\033[41;37mPLZ note this ${Node_Pid_date} is in ignore_dict. Will HK. Kindly double check in SNOW.\033[0m"
#                          ls -lt ${errorFolder}/${Node_Pid}*
                      /bin/mv -v ${errorFolder}/${Node_Pid}* ${houseKeepPath};
                      for((i=1;i<=3;i++));do echo -en "\a";sleep 1;done
                  fi
                 done
                 fi
              done
              if [[ $loop_count -gt 0 ]];
                then Beep;
              fi
            fi
            hk_refs=`find ${supportFolder}/luis/SYSTXERROR/ -type f -cmin -1 | awk -F "/" '{print $NF}'|tr '\n' ' '`
            if [ -n "$hk_refs" ];
            then echo -e "\033[41;37mPLZ note this ${hk_refs} will be auto-HKed. Kindly double check in SNOW if it needs to be check further.\033[0m"
#This is one bug for below function to display the remove log. As due to the for-loop, it will only display one file
#            cat ${supportFolder}/luis/TMP/syst_hk_record.txt;
            for((i=1;i<=3;i++));do echo -en "\a";sleep 1;done
            fi
            echo -e "Next check will be executed ${gap} minutes later.\nPress Enter to check again immediately.\nInput any command to run immediately.";
            read -t "$((${gap}*60))" command;
            sleep 1;
        fi
    done
fi
}


monitor "$@";
#!/bin/bash

#author: bucat

[[ "$1" == "" || "$2" == "" ]] && echo -e Usage: checkclean_up.sh {Time} {Count}, \
such as checkclean_up.sh 100 50 means errors within 100 days with 50 cleanups && exit

SUP_ERR=/app/sword/schenker/support/error;

echo -e "\033[41;37mPID:     \t\tCount:\033[0m";

for DIR_NAME in `ls -l ${SUP_ERR} | grep '^d' | awk '{print $9}'|grep '^[A-Z]'`;do
    INTER_value=`find ${SUP_ERR}/${DIR_NAME}/ -maxdepth 1 -mtime -$1 -type f | wc -l`;
    File_COUNT=$((${INTER_value}/2))
        if [ ${File_COUNT} -ge "$2" ];then
            PROCESS_ID=`find ${SUP_ERR}/${DIR_NAME}/ -maxdepth 1 -mtime -$1 -type f|head -1|xargs basename|cut -c 1-10 2>/dev/null`;
            echo -e ${PROCESS_ID} '\t\t' ${File_COUNT};
        fi
done
#!/bin/bash


######################################################################
#Program:       Create this script to handle exp and imp file quickly
#History:       2020.07.28      Luis    Release
#               2020.07.28      Luis    Add issue handling suggestion
#
######################################################################

#judge if the $1 you input is correct or not
BOUND=`echo $1|sed 's/.*\([oi][a-zA-Z]*bound\).*/\1/'`;

#quote the llinbound & lloutbound script under backup folder
if [ $BOUND == "inbound" ];then /app/sword/schenker/support/luis/backup_folder/llinbound.sh $1;
elif [ $BOUND == "outbound" ];then /app/sword/schenker/support/luis/backup_folder/lloutbound.sh $1;
else echo -e "Kindly input correct references!";
fi

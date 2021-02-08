#!/bin/bash

##########################################################################################################
# This script aims to check errors for Scintilla and Shield
# Kindly contact luis.liu@dbschenker.com if you have any concerns
#
#       1/14/2021      -Luis              Script Created
##########################################################################################################

if [[ "$1" == "" ]];then folder=jmsclients;SS=Scintilla
elif [[ "$1" == "h" ]];then folder=jmsclientsShield; SS=Shield 
else echo -e "Kindly input nothing or value h.";exit;fi

d=`date '+%Y/%m/%d'`
echo "Searching for 'error/$d/*.arc' for $SS"
find /app/sword/schenker/$folder |grep "error/$d" |grep .arc

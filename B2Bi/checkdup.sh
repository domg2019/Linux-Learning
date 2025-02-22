#!/bin/bash

#################################################################################
#Program:       Create this script to housekeeping outbound pending files easily
#History:       2022.04.05              Released
#Author:        Luis Liu        luis.liu@dbschenker.com
#################################################################################

Current_dir=`pwd`
File_count=`ls | wc -l`
[[ $File_count -eq 0 ]] && echo -e "No messages under $Current_dir ! Exit !" && exit
File_dup_count=$(for i in `ls $Current_dir`;do md5sum $i 2>/dev/null;done| sort -k1|uniq -w 32 -c -d|sort -r| head -1 | cut -c 1-7|bc)
[[ $File_dup_count -eq 1 ]] && echo -e "No duplicated messages under $Current_dir ! Exit !" && exit
echo -e "There are totally $File_count messages and here is the list with duplicates below:"
for i in `ls $Current_dir`;do md5sum $i 2>/dev/null;done| sort -k1|uniq -w 32 -c -d|sort -r| head -10
echo

#for i in `ls`;do md5sum $i 2>/dev/null;done| sort -k1|uniq -w 32 -c|sort -r| head -10
#for i in `ls`;do md5sum $i 2>/dev/null;done|cut -c 1-32|sort| uniq -c| head -1 | cut -c 1-7|bc


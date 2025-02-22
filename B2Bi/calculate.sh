#!/bin/bash

MASSAUTO=/app/sword/schenker/support/luis/MASSAUTO
Error=/app/sword/schenker/data/error

Year=$(date '+%Y');
Today=$(date '+%Y_%m%d');


for FILE in `ls /app/sword/schenker/support/luis/TEST`;
do if [ `grep -o Parallel $FILE|uniq|wc -l|bc` -eq 1 ]
        then c_line=`cat $FILE | grep -n -E 'CET$' | awk -F: '{print $1}' | wc -l`
                 for ((c_check=1;c_check<=$c_line;c_check++))
                 do 	#create singal txt only contains one massfilter result
						f_PID=`echo $FILE|awk -F. '{print $1}'`
                        touch /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                        #Get the last line for one process
                        X=`grep -n -E 'CET$' $FILE | awk -F: '{print $1}' |  sed -n 1p`
                        #Caculate the last 13 lines:Y
                        Y=`echo $X-11 | bc`
                        #Get the remafi line:
                        R=`grep -n -E '^>>>remafi' $FILE | awk -F: '{print $1}' |  sed -n 1p`
                        S=`echo $R+5 | bc`
                        if [ "$X" -gt 39 ];then
                                sed -n 1,"$S"p $FILE  >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                                echo "......" >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                                sed -n $Y,"$X"p $FILE  >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                        else sed -n 1,"$X"p $FILE >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt;
                        fi
						#remove lines that already checked
                        sed -i 1,"$X"d $FILE
                        echo -e -n "Number of files: $c_check"
                        echo -e "+++++++++++++++++++++++++++"
                done
			rm -rf $FILE
	elif [ `grep -o SerialLarge $FILE |uniq|wc -l|bc` -gt 0 ]
		then c_line=`cat $FILE | grep -n -E 'CET$' | awk -F: '{print $1}' | wc -l`
                 for ((c_check=1;c_check<=$c_line;c_check++))
                 do 	#create singal txt only contains one massfilter result
						f_PID=`echo $FILE|awk -F. '{print $1}'`
                        touch /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                        #Get the last line for one process	
						A=`grep -n -E '^Deleted' $FILE | awk -F: '{print $1}' |  sed -n 1p`
						X=`echo $A+1 | bc`
						#Caculate the last 30 lines:Y as it's serial
						Y=`echo $X-30 | bc`		
                        #Get the remafi line:
                        R=`grep -n -E '^>>>remafi' $FILE | awk -F: '{print $1}' |  sed -n 1p`
                        S=`echo $R+5 | bc`
                        if [ "$X" -gt 39 ];then
                                sed -n 1,"$S"p $FILE  >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                                echo "......" >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                                sed -n $Y,"$X"p $FILE  >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt
                        else sed -n 1,"$X"p $FILE >> /app/sword/schenker/support/luis/$f_PID.$c_check.txt;
                        fi
						#remove lines that already checked
						sed -i 1,"$X"d $FILE
                        echo -e -n "Number of files: $c_check"
                        echo -e "+++++++++++++++++++++++++++"
				 done
			rm -rf $FILE
	fi
done

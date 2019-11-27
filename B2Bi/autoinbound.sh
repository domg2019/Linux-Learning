#!/bin/bash

/app/sword/schenker/comsys/COMS1_01/agr/ELIXWINBIS_inbound/exp
/app/sword/schenker/comsys/COMS1_01/archive/scheduler/ELIXWINBIS_inbound/

COM=/app/sword/schenker/comsys/COMS1_01/
COMAGR=/app/sword/schenker/comsys/COMS1_01/agr
COMARC=/app/sword/schenker/comsys/COMS1_01/archive/scheduler/

DATE=`date +%Y/%m`

#list the whole pending file name with agreement and count
FILE=`ls /app/sword/schenker/comsys/COMS1_01/agr/$1/exp`
FACH=`find /app/sword/schenker/comsys/COMS1_01/archive/scheduler/$1/$DATE -name "$FILE" | wc -l |bc`
#judge if the file is already in scheduler folder or not
if [ "$FACH" == 0 ]
	then omv ${COMAGR}/$1/${FILE} ${COM}/comexp_ok
		 sleep 10
		 grep $FILE ${COM}/log/log
	elif [ "$FACH" == 1 ]	
		then echo -e "The file is already transferred successfully!"
			 echo -e ">>>Housekeeping in the shell"
			 l -d ${COM}/$1 &>/dev/null
			 if [ "$?" == 0  ]
				then omv ${COMAGR}/$1/${FILE} 	${COM}/$1
				else omv ${COMAGR}/$1/${FILE} $sup/error/${DATE}
			fi
fi




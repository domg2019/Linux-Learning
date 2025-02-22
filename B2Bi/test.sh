##!/bin/bash
#
#for i in `cat $CONFIG/t1config.txt`;do
#	impno=`grep $i/impwork $CONFIG/listcs.txt|cut -d: -f1`
#	high=`grep total $CONFIG/listcs.txt|wc -l|bc`
#	for((i=1;i<=$high;i++))
#	do ttno=`grep -n total $CONFIG/listcs.txt|sed -n "$i"p|cut -d: -f1`
#	if [ $ttno -gt $impno ]
#	then sed -n "$impno","$ttno"p $CONFIG/listcs.txt
#	exit 10
#	fi
#	done
#done

export COMSYSBASEDIR="/app/sword/schenker/comsys"

agrgrep2 () {
        [ "$1" == "" ] && echo "agrgrep2 - searches for PATTERN in agreements that contain CONDITION" && echo "SYNTAX:       agrgrep2 <PATTERN> <condition>" && return 1;
        [ "$2" == "" ] && echo "agrgrep2 - searches for PATTERN in agreements that contain CONDITION" && echo "SYNTAX:       agrgrep2 <PATTERN> <condition>" && return 1;
        if [ "$3" == "" ]
        then
                for agreementname in $(find $COMSYSBASEDIR/COMS*/agr/ -maxdepth 2 -iname \*.xml -exec grep -l $2 {} \; );
                do
                        grep -H $1 $agreementname;
                done
        else
                for agreementname in $(find $COMSYSBASEDIR/$3/agr/ -maxdepth 2 -iname \*.xml -exec grep -l $2 {} \; );
                do
                        grep -H $1 $agreementname;
                done
        fi
}

       -H, --with-filename
              Print the file name for each match.  This is the default when there is more than one file to search.

       -h, --no-filename
              Suppress the prefixing of file names on output.  This is the default when there is only one file (or only standard input) to search.

[comsys@b2biprdcom1:/app/sword/schenker/support/luis]$
find /app/sword/shared/ftpserver/customer/ -maxdepth 3 -type f -name "SCANSIONI.lnk" 2>/dev/null
/app/sword/shared/ftpserver/customer/lmeridionale/from_lmeridionale/SCANSIONI.lnk

>>>pending file as below:
**********************************************************************************************************************
/app/sword/schenker/comsys/COMS1_01/agr/SCDEE2HGFL_outbound/imp:         pending files: 4285
**********************************************************************************************************************
     oldest file:-rw-rw-rw- 1 comsys b2bi    720 Aug 21 22:32 SCDEE2HGFL_outbound.05225406.Schenker_HAGER_20220821223248_141.dat
most recent file:-rw-rw-rw- 1 comsys b2bi 4960 Aug 31 18:48 SCDEE2HGFL_outbound.26288692.Schenker_HAGER_20220831184823_429.dat
**********************************************************************************************************************


c24fcfe7ddd438f1ccc844f042fb9851
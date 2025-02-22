#alias
alias ..='cd ..';
alias ...='cd ../..';
alias ll='ls -l';
alias l='ls -l';
alias cp='cp -i';
alias mv='mv -i';
alias rm='rm -i';
alias frm='/usr/bin/rm';
alias l.='ls -d .* --color=auto';
alias allen='cd $sup/allen';
alias new='ls -lt | grep -v "^total" | head';
alias old='ls -ltr | grep -v "^total" | head';
alias grep='ggrep --color=auto';
alias egrep='grep -E';
alias fgrep='grep -F';
alias vi='vim';
alias xfb='cd /ext/schenker/logarchive/';
alias a1='ssh -o StrictHostKeyChecking=no xibapprd1.dc.signintra.com';
alias a2='ssh -o StrictHostKeyChecking=no xibapprd2.dc.signintra.com';
alias a3='ssh -o StrictHostKeyChecking=no xibapprd3.dc.signintra.com';
alias a4='ssh -o StrictHostKeyChecking=no xibapprd4.dc.signintra.com';
alias g1='ssh -o StrictHostKeyChecking=no xibgwprd1.dc.signintra.com';
alias g2='ssh -o StrictHostKeyChecking=no xibgwprd2.dc.signintra.com';
alias g3='ssh -o StrictHostKeyChecking=no xibgwprd3.dc.signintra.com';
alias g4='ssh -o StrictHostKeyChecking=no xibgwprd4.dc.signintra.com';
alias FTP='ssh -o StrictHostKeyChecking=no amtrix@xibftprd1.dc.signintra.com';

#values
houseKeepPath=$sup/error/$(date "+%Y/%m/");
downloadPath=$sup/allen/download/$(date "+%Y%m%d");
allen=${sup}/allen;
ftpLog="/ext/schenker/prot/proftpd/proftpd.access_log";

mkdir -p ${downloadPath};
chmod 777 ${downloadPath};
mkdir -p ${houseKeepPath};

#functions
function getBDID()
{
    if [[ '' != $1 ]];then
        agreementID=$(echo $1 | cut -d\. -f1);
        counter=$(echo $1 | cut -d\. -f2);
        prefix="${agreementID}.${counter}";
        agreementPath="$(/ext/schenker/toolslocal/agrcheck ${agreementID} | ggrep -B 1 ${agreementID} | head -1)";
        cat "${agreementPath}/../archive/imptmp/${prefix}";
    fi
}

function massinfo()
{
    err;
    echo -n "MassFilterFileNumber of $1:";
    ls -l | grep "MassFilter" | grep $1 | grep -c ".att$";
    ls -l | grep "MassFilter" | grep $1 | head;
}

function runmass()
{
    . $FRAME_ROOT/tools/ScriptFunctions;
    if [[ $1 != '' ]]; then
        if [[ -e "/tmp/remafi_$1.lck" ]];then
            echo "Remafi lock for $1(/tmp/remafi_$1.lck) already exist, check below info to confirm if someone is running remafi."
            for deviceid in $(finger| grep -v "^Login" | awk '{print $3}')
            do
                count=$(ps -ef | grep -w ${deviceid} | grep -v "grep" | grep -c "remafi");
                if [[ ${count} != 0 ]]; then
                    finger | grep -w ${deviceid};
                    ps -ef | grep -w ${deviceid} | grep -v "grep" | grep "remafi";
                fi
            done
        else
            massinfo $1;
            INTEGRATIONTYPE=$(SQLselect INTEGRATIONTYPE XIB_PROCESSIDPROPERTIES PROCESSIDCODE $1 | sed 's#^.* ##');
            echo "Integration type : ${INTEGRATIONTYPE}";
            if [[ "${INTEGRATIONTYPE}" == "Parallel" ]];then
                echo -e "\n>>>deletemassfilterflag $1";
                echo | deletemassfilterflag $1;
                echo -e "\n>>>remafi $1 2";
                remafi $1 2;
            elif [[ "${INTEGRATIONTYPE}" == "Serial" ]]; then
                echo -e "\n>>>remafi $1 7";
                remafi $1 7;
                echo -e "\n>>>deletemassfilterflag $1";
                echo | deletemassfilterflag $1;
            fi
        fi
    fi
}

function download()
{
    cp $@ ${downloadPath};
    chmod 666 ${downloadPath}/*;
}

function downloadError()
{
    cp ${houseKeepPath}/$@ ${downloadPath};
    chmod 666 ${downloadPath}/*;
}

function monitor()
{
    cd $sup/monitor;
    ./monitor.sh $@;
}

function catError()
{
    cat ${houseKeepPath}/$@;
}

function checkDEA()
{
    ssh -o StrictHostKeyChecking=no xibgwprd1.dc.signintra.com "for stream in \$(/opt/sfw/bin/seq 4); do /ext/schenker/toolslocal/PassportTool/ppt -s \$stream -sd -i $1; done";
}

function countByTime()
{
    ls -lt | grep -v "^total" | awk '{print $6" "$7" "$8}' | uniq -c;
}

function countByAgrOrPID()
{
    ls | cut -d\. -f1 | sort | uniq -c | sort -nr;
}

function sameFile()
{
    oldREF=${REF};
    REF='';

    md5TmpFile="/tmp/md5_$(date "+%Y%m%d%H%M%S").tmp";
    gfind /tmp/ -mtime +1 -name "md5_*.tmp" -exec /usr/bin/rm {} \; 2>/dev/null;
    gfind . -maxdepth 1 -type f -exec md5sum {} \; > ${md5TmpFile};
    cat ${md5TmpFile} | cut -c-32 | sort | uniq -c | while read rec
    do
        if [[ $(echo ${rec} | awk '{print $1}' | bc) -gt 1 ]];then
            MD5=$(echo ${rec} | awk '{print $2}');
            echo "MD5: ${MD5}";
            grep ${MD5} ${md5TmpFile} | awk '{print $2}';
            echo;
        fi
    done

    /usr/bin/rm ${md5TmpFile};
    REF=${oldREF};
}

function hk()
{
    if [[ $1 != '' && $(echo $1 | grep -Eo [A-Z_0-9]{10}) == $1 ]]; then
        err; clean; echo;
        processID=$1;
        hkTmpFile="/tmp/hk_${processID}_$(date "+%Y%m%d%H%M%S").tmp";
        gfind /tmp/ -mtime +1 -name "hk_*.tmp" -exec /usr/bin/rm {} \; 2>/dev/null;
        if [[ $(ls /tmp/hk_${processID}_*.tmp 2>/dev/null | wc -l | bc) != 0 ]];then
            echo "TMP file found for process ${processID} in /tmp as below";
            ls /tmp/hk_${processID}_*.tmp;
            echo "Possible root cause: Someone is running this command right now.";
            echo "Please check with your colleagues.";
            echo "Only remove the files if no one else is running hk (please check with ps -efa | grep hk | grep ${processID} | grep -v grep) and try again.";
        else
            ls | grep -v "MassFilter" | grep "${processID}.*.att" | sed 's/.att$//g' > ${hkTmpFile};
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
                /opt/sfw/bin/mv -v ${file}* ${houseKeepPath};
            done
            /usr/bin/rm ${hkTmpFile};
        fi
    else
        echo "Please input a valid processID as parameter.";
    fi
}

function clean()
{
    err;
    echo "============$(date "+%Y-%m-%d %H:%M:%S")==============" >> ${sup}/allen/clean.log;
    clean_up2 -v | tee -a ${sup}/allen/clean.log;
}

function oldFile()
{
    scan_out="$sup/allen/old_file_scan_record/$(date "+%Y%m")/old_file_scan_$(date "+%Y%m%d_%H%M%S")_$(hostname)";
    mkdir -p $sup/allen/old_file_scan_record/$(date "+%Y%m")/;
    chmod 777 $sup/allen/old_file_scan_record/$(date "+%Y%m");
    touch ${scan_out};
    if [[ "/app/xib/home/xib" == "${HOME}" ]];then
        list2 -fileagemin=30 | tee ${scan_out}; chmod 666 ${scan_out};
    elif [[ "/app/xib/home/amtrix" == "${HOME}" ]];then
        list2 -runbycron | tee ${scan_out};
    fi
}

function catAgr()
{
    if [[ $1 != '' ]]; then
        cat /ext/comsys*/agr/$1/$1_dump.xml;
    fi
}

function cdAgr()
{
    if [[ $1 != '' ]]; then
        cd /ext/comsys*/agr/$1/;
    fi
}

function grepAgr()
{
    if [[ $1 != '' ]]; then
        echo "Please input the field your keyword belongs to.";
        echo "Protocol|AgrID|Dir|CmdFile|RemoteHost|User|Password|RemoteFileMask|RemoteDir|Archive|Counter|DstFileName|KeepArchive|LocalDstDir|Mode|RunMode";
        read filed;
        if [[ ${filed} == '' ]];then
            keyword=$1;
        else
            keyword="<${filed}>.*$1.*</${filed}>";
        fi
        for gwServer in xibgwprd1.dc.signintra.com xibgwprd2.dc.signintra.com xibgwprd3.dc.signintra.com xibgwprd4.dc.signintra.com
        do
            echo -e "\n===${gwServer}===";
            ssh -o StrictHostKeyChecking=no ${gwServer} "for agr in \$(/usr/sfw/bin/ggrep -El \"${keyword}\" /ext/comsys*/agr/*/*_dump.xml); do echo \${agr}; cat \${agr}; echo; done" 2>/dev/null;
        done
        echo;
    fi
}

function cdArchive_G()
{
    if [[ $1 != '' ]]; then
        cd /ext/comsys*/archive/scheduler/$1/;
        cd $(date +"%Y/%m/%d");
    fi
}

function cdArchive_A()
{
    if [[ $1 != '' ]]; then
        processID=$1;
        if [[ $2 != '' ]];then
            cd "/archive/${processID:0:4}/${processID:4:10}/IN";
            cd "$(/opt/sfw/bin/date -d "$2" +"%Y/%m/%d")";
        else
            cd "/ext/schenker/archive/${processID:0:4}/${processID:4:10}/IN/$(date +"%Y/%m/%d")";
        fi
    fi
}

function ref()
{
    for file in $(ls /ext/schenker/data/error/*$1*.att | grep -v "MassFilter")
    do
        basename ${file};
        transaction=$(ggrep -A1 -E '^TransactionAttribute$' ${file} | grep -v "^TransactionAttribute$" | head -1);
        echo "Date/Time : $(echo ${transaction} | ggrep -Eo "[0-9]{4}-[a-zA-Z]{3}-[0-9]{2} [0-9:]{8}") CET";
        echo "TRID : $(ggrep -A1 -E '^TRID$' ${file} | sed -n '2p')";
        BDIDRefValues=$(ggrep -A1 -E '^BDIDRefValues$' ${file} | grep -v "^BDIDRefValues$" | head -1);
        if [[ ${BDIDRefValues} != '' ]];then
            echo ${BDIDRefValues:0:99} | awk -F\" '{print "BDID : "$2}';
            echo $BDIDRefValues | grep -Eo "\{[^{}]+\}" | awk -F\" '{print $2" : "$4}'
        fi
        echo "TransactionAttribute : ";
        echo -e "${transaction}\n";
    done
}

function deepRef()
{
    if [[ $1 != '' ]]; then
        fileName=$1;
        echo "Please choose one reference category from below, or press Enter to check all details";
        grep -E "^[^{]" ${fileName};
        read refCate;
        if [[ ${refCate} == '' ]];then
            for refCate in $(grep -E "^[^{]" $1)
            do
                echo -e "\n${refCate}";
                grep -h -A1 ${refCate} ${fileName} | grep -v "^${refCate}" | head -1 | grep -Eo "\{[^{}]+\}";
            done
        else
            grep -h -A1 ${refCate} ${fileName} | grep -v "^${refCate}" | head -1 | grep -Eo "\{[^{}]+\}";
        fi
    fi
}

function 0byte()
{
    for emptyFile in $(gfind $err -size 0 -name "*$1*" -type f)
    do
        fileName=$(basename ${emptyFile});
        agrName=$(echo ${fileName} | cut -d\. -f1);
        oriName=$(echo ${fileName} | cut -d\. -f3-);
        archiveFolder="/ext/comsys*/archive/scheduler/${agrName}/";
        echo "===0 byte file name==="
        echo "${emptyFile}";
        echo -e "\n===Agreement parameters of ${agrName}===";
        catAgr ${agrName};
        echo -e "\n===checking file with the same name in archive folder(${archiveFolder})===";
        echo "0 byte file received : ";
        gfind ${archiveFolder} -name "*${oriName}" -size 0 -type f -exec ls -l {} \;;
        echo "file with content : ";
        gfind ${archiveFolder} -name "*${oriName}" -size +0 -type f -exec ls -l {} \;;

        comsysLogFile="/ext/comsys*/agr/${agrName}/../../log/log";
        comsysLogFileYesterday="/ext/comsys*/agr/${agrName}/../../log/log.$(/opt/sfw/bin/date -d "-1 day" "+%Y-%m-%d")";
        echo -e "\n===checking comsys log===";
        grep ${oriName} ${comsysLogFile} ${comsysLogFileYesterday};

        remoteHost=$(grep '<RemoteHost>' /ext/comsys*/agr/${agrName}/${agrName}_dump.xml | sed "s/<[^<>]*>//g")
        if [[ "xibftp" == ${remoteHost} || "xibftprd" == ${remoteHost} ]];then
            protocol=$(grep '<Protocol>' /ext/comsys*/agr/${agrName}/${agrName}_dump.xml | sed "s/<[^<>]*>//g");
            if [[ "ftp" == ${protocol} ]];then
                echo -e "\n===checking ftp access log===";
                ssh -o StrictHostKeyChecking=no amtrix@xibftprd1.dc.signintra.com "/opt/amtcftp/tools/support/bin/ggrep ${oriName} /ext/schenker/prot/proftpd/proftpd.access_log; /usr/bin/zcat \$(ls -rt /progs/adm_sav/proftpd.access_log_* | tail -1) | /opt/amtcftp/tools/support/bin/ggrep ${oriName}";
            elif [[ "script" == ${protocol} ]];then
                echo -e "\n===checking sftp access log===";
                ssh -o StrictHostKeyChecking=no amtrix@xibftprd1.dc.signintra.com "/opt/amtcftp/tools/support/bin/ggrep ${oriName} /app/sftplog/sftplog.log; /usr/bin/zcat \$(ls -rt /progs/adm_sav/sftplog.log_* | tail -1) | /opt/amtcftp/tools/support/bin/ggrep ${oriName}";
            elif [[ "ftps" == ${protocol} ]];then
                echo -e "\n===checking ftps access log===";
                ssh -o StrictHostKeyChecking=no amtrix@xibftprd1.dc.signintra.com "/opt/amtcftp/tools/support/bin/ggrep ${oriName} /ext/schenker/prot/proftpd/proftpd-tls.access_log; /usr/bin/zcat \$(ls -rt /progs/adm_sav/proftpd-tls.access_log_* | tail -1) | /opt/amtcftp/tools/support/bin/ggrep ${oriName}";
            fi
        fi
        echo "=====================================================";
    done
}

function mysplit()
{
    bigFile=$1;
    if [[ ! -f /ext/schenker/support/big_file/mysplit.sh ]];then
        echo "Script /ext/schenker/support/big_file/mysplit.sh not found.";
    elif [[ "" == ${bigFile} ]];then
        hint mysplit;
    elif [[ ! -f ${bigFile} ]];then
        echo "Big file not found.";
    else
        cp ${bigFile} /ext/schenker/support/big_file/;
        mv ${bigFile} ${houseKeepPath};
        cd /ext/schenker/support/big_file/;
        fileName=$(basename ${bigFile});
        ./mysplit.sh ${fileName};
    fi
}

function age()
{
    keyword="$1.*";
    currentSec=$(/opt/sfw/bin/date '+%s');
    for record in $(/opt/sfw/bin/ls -l --time-style='+%s' | grep -v "^total" | grep "${keyword}" | awk '{print $6"|"$7}')
    do
        fileName=$(echo ${record} | cut -d \| -f2);
        fileSec=$(echo ${record} | cut -d \| -f1);
        deltaSec=$(echo "${currentSec} - ${fileSec}" | bc);
        deltaMin=$(echo "scale=2;${deltaSec} / 60" | bc);
        deltaHr=$(echo "scale=2;${deltaSec} / 3600" | bc);
        deltaDay=$(echo "scale=2;${deltaSec} / 86400" | bc);
        echo "${fileName}:${deltaSec}(secs)|${deltaMin}(mins)|${deltaHr}(hrs)|${deltaDay}(days)";
    done
}

function hkOutboundFile()
{
    if [[ -e $1 ]]; then
        fileName=$(basename $1);
        agrName=$(echo ${fileName} | cut -d\. -f1);
        counter=$(echo ${fileName} | cut -d\. -f2);
        comsysName=$(echo /ext/comsys*/agr/${agrName} | grep -Eo "comsys[0-9]*");
        /opt/sfw/bin/mv -v /ext/${comsysName}/impwork/${agrName}.${counter}* ${sup}/${comsysName}/impwork/;
        /opt/sfw/bin/mv -v /ext/${comsysName}/archive/imptmp/${agrName}.${counter}* ${sup}/${comsysName}/archive/imptmp/;
        /opt/sfw/bin/mv -v /ext/${comsysName}/agr/${agrName}/imp/${agrName}.${counter}* ${sup}/${comsysName}/${agrName}/imp/;
    else
        echo "Cannot find file $1";
    fi
}

function catlist()
{
    echo "TODO";
    #TODO
}

function exp()
{
    echo "TODO";
    #TODO
}

function checkRemote()
{
    echo "TODO";
    #TODO
}

function tmcheck()
{
	NOTOOMUCH=`ls /ext/comsys2001/comexp_too_much 2>/dev/null | wc -l`;
	NOIMPWORK=`ls /ext/comsys2002/impwork 2>/dev/null | wc -l`;


	echo -e "==========Check the UDS agreement too_much issue==============";
	echo -e "/ext/comsys2001/comexp_too_much:";
	ls /ext/comsys2001/comexp_too_much 2>/dev/null | awk -F. '{print $1 "." $2}' | uniq -c | sort -r;
	echo -en "Number of files in this folder is:"; 
	ls /ext/comsys2001/comexp_too_much 2>/dev/null | wc -l;
	echo -en "/ext/comsys2002/impwork";
	ls /ext/comsys2002/impwork 2>/dev/null | wc -l ;
	echo -en "/ext/comsys2002/agr/UDS_COROUT_NEWTOPS_outbound/imp"; 
	ls /ext/comsys2002/agr/UDS_COROUT_NEWTOPS_outbound/imp 2>/dev/null | wc -l;
	date;

}

function Mtmcheck()
{
	str1=`echo -n $1 | wc -c`;
	str2=`find /ext/comsys2001/comexp_too_much -name "$1*" | wc -l`;
	if [[ $str -lt 23 ]] || [[ $str2 -eq 0 ]];
	then 	echo "Please input correct variable!"
	else	for i in `find /ext/comsys2001/comexp_too_much -name "$1*" |tail -10000`;
			do 	/opt/sfw/bin/mv -v $i /ext/comsys2001/comexp_ok/ >> /ext/schenker/support/luis/$1;
				usleep 100000;
			done; 
	fi
}


function hint()
{
    if [[ "" == $1 ]];then
        echo "alias(use alias to view the shortcuts):";
        echo "..|...|ll|l|allen|new|old|grep|vi|xfb|a1|a2|a3|a4|g1|g2|g3|g4|FTP";
        echo "values(use echo to check the content):";
        echo "houseKeepPath|downloadPath|allen|ftpLog";
        echo "functions(use hint to read the instruction):";
        echo "hint|hk|hkOutboundFile|ref|deepRef|0byte|runmass|mysplit|monitor|checkDEA|massinfo|sameFile|age|catError|clean|oldFile|catAgr|cdAgr|grepAgr|cdArchive_G|cdArchive_A|countByTime|countByAgrOrPID|download|downloadError|getBDID";
    else
        case $1 in
            hint)
                echo "Short description: Output the introduction of the functions.";
                echo "Usage: hint to get list of names of alias, values and functions.";
                echo "Usage: hint {function name} to get a hint of this function, e.g. hint ref to output the introduction of function ref.";
            ;;
            getBDID)
                echo "Short description: Get BDID of the old files pending in Gateway.";
                echo "Usage: getBDID {name of old file} to output the BDID of this file.";
            ;;
            massinfo)
                echo "Short description: List the MassFilter file info in error folder.";
            ;;
            runmass)
                echo "Short description: List the file info of MassFilter; Check the integration type of the process, run remafi and deletemassfilterflag in proper order.";
                echo "Usage: runmass {processID}.";
            ;;
            download)
                echo "Short description: Copy file to folder: ${downloadPath}.";
                echo "Usage: download {name of file in current folder}.";
            ;;
            downloadError)
                echo "Short description: Copy file from ${houseKeepPath} to ${downloadPath}.";
                echo "Usage: downloadError {name of file in housekeeping folder}.";
            ;;
            catError)
                echo "Short description: Output the content of file in folder ${houseKeepPath}.";
                echo "Usage: catError {name of file in housekeeping folder}.";
            ;;
            monitor)
                echo "Short description: Run monitor.sh anywhere.";
            ;;
            checkDEA)
                echo "Short description: Check DEA information for all streams.";
                echo "Usage: checkDEA {Partner Id}, e.g. checkDEA 14060704780001900.";
            ;;
            countByTime)
                echo "Short description: Count files group by timestamp.";
            ;;
            countByAgrOrPID)
                echo "Short description: Count files group by agreementID or processID.";
            ;;
            sameFile)
                echo "Short description: Find the file share the same content.";
            ;;
            hk)
                echo "Short description: Output the file list and file info, then move the files to housekeeping folder: ${houseKeepPath}";
                echo "Usage: hk {processID}";
            ;;
            clean)
                echo "Short description: Run clean_up2 and record the output into ${sup}/allen/clean.log.";
            ;;
            oldFile)
                echo "Short description: Run list2 to find the files older than 30 minutes on both FTP and Gateway. This command will record output into file in $sup/allen/old_file_scan_record/.";
            ;;
            catAgr)
                echo "Short description: Output xml parameters of an agreement.";
                echo "Usage: catAgr {agreementID}.";
            ;;
            cdAgr)
                echo "Short description: Goto the agreement folder.";
                echo "Usage: cdAgr {agreementID}.";
            ;;
            grepAgr)
                echo "Short description: Find agreement in 4 gateways with any keyword.";
                echo "Usage: grepAgr {keyword}.";
            ;;
            ref)
                echo "Short description: Fetch some file info like timestamp, BDID, TRID...";
                echo "Usage: ref {processID}.";
            ;;
            deepRef)
                echo "Short description: Fetch some more info from att file.";
                echo "Usage: ref {att file name}.";
            ;;
            0byte)
                echo "Short description: When there is/are empty file(s) in error folder. Check archive folder, comsys log, FTP/FTPS/SFTP log according to the xml parameter.";
                echo "Usage: 0byte to check all empty file in error folder. 0byte {keyword} to check the old file match the keyword.";
            ;;
            cdArchive_G)
                echo "Short description: Goto archive folder of an agreement on a gateway server.";
                echo "Usage: cdArchive_G {agreementID}.";
            ;;
            cdArchive_A)
                echo "Short description: Goto archive folder of a process on an app server.";
                echo "Usage: cdArchive_A {processID} to go to the archive for today.";
                echo "Usage: cdArchive_A {processID} {date(YYYYMMDD)} to go to the archive folder for a certain date.";
            ;;
            mysplit)
                echo "Short description: split big file and resend.";
                echo "Usage: mysplit {filename}.";
            ;;
            age)
                echo "Short description: output the age of file or folder.";
                echo "Usage: age to output the duration of file or folder under current directory since last update.";
                echo "Usage: age {keyword} to output the duration of file or folder which fit the keyword under current directory since last update.";
            ;;
            hkOutboundFile)
                echo "Short description: Housekeeping the outbound file.";
                echo "Usage: hkOutboundFile {filename} to move the outbound file(impwork/imptmp/imp) to housekeeping folder.";
            ;;
            *)
                echo "Please input a valid function name.";
            ;;
        esac
    fi
}


hint;
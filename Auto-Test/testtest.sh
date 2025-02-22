function checkError()
{
    fileCount=$(ls "${errorFolder}" | grep -c "\.att$" | bc);
    [[ "${fileCount}" != "0" ]] && echo -en "\a";
    echo -n "Massfilter : ";
    ls "${errorFolder}" | fgrep "MassFilter" | grep -c "\.att$";
    ls "${errorFolder}" | fgrep "MassFilter" | grep "\.att$" | cut -d\. -f2 | sort | uniq -c | while read line
    do
        echo "    ${line}";
    done
    echo -n "Error : ";
    ls "${errorFolder}" | fgrep -v "MassFilter" | grep -c "\.att$";
    ls "${errorFolder}" | fgrep -v "MassFilter" | grep "\.att$" | cut -d\. -f1 | sort | uniq -c | while read line
    do
        echo "    ${line}";
        processID=$(echo "${line}" | awk '{print $2}')
        ls -l | fgrep "${processID}." | while read subLine
        do
            echo "        ${subLine}";
        done
    done
}

function monitor()
{
    gap=$(echo $1 | bc);
        beep=$(echo $2);
    command='';
    if [[ "${gap}" == "" ]]; then
        checkError;
    else
        while true
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
                echo -e "Next check will be executed ${gap} seconds later.\nPress Enter to check again immediately.\nInput any command to run immediately.";
                read -t "${gap}" command;
            fi
        done
    fi
}
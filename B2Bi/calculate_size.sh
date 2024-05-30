#!/bin/bash

# This script is used to check the totaly file size older than specific days($1) under support folder older 
# Luis Liu  luis.liu@dbschenker.com

[[ $1 == "" ]] && echo "Kindly input one number(days) after the script. Usage calculate_size.sh + {365}" && exit

total_size=0

while IFS= read -r -d '' file; do
        size=$(stat -c%s "$file")
        total_size=$((total_size + size))
done < <(find /app/sword/schenker/support -type f -mtime +$1 -print0)

total_size=$((total_size/1024/1024))

echo "Total size of files older than $1 days: $total_size M bytes"

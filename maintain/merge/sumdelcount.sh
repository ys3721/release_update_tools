#!/usr/bin/env bash
#Auther Yao Shuai @date 2020-06-03

total_count=0
for f in /data3/merge/del_infos/*.deletechar
do
  if [ -e $f ]
  then
    month=$(ls -ltr $f | awk '{print $6}' | sed 's/月//')
    if [[ $month -eq 12 ]] || [ $month -eq 11 ]
    then
      count=$(cat "$f" | wc -l)
      echo -n $f
      echo "del" "$count"
      ((total_count+=count))
    fi
  fi
done
echo total_count = $total_count
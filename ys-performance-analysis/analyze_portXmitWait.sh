#!/bin/bash

for dir in `ls ~/ibdiagnet_logs`
do

date=`echo $dir | grep -oE '([a-zA-Z0-9]+_){3}([0-9]+:){2}[0-9]+_2014'`
file=ibdiagnet_logs/$dir

sed -n '/START_PM_INFO/,/END_PM_INFO/p' ${file} > PortXmitWait_${date}.txt

sed '/PM_INFO/d' PortXmitWait_${date}.txt| cut -d ',' -f2,3,20|sort -t, -nk3 -r > portXmitWait_${date}_ordered.txt
perl -w translate_guids.pl $date

echo "Cleaning up..."
rm  PortXmitWait_${date}.txt portXmitWait_${date}_ordered.txt 
done

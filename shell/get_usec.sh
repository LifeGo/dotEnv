cat dmesg.001.log | grep "\ initcall\ " | sed 's/\ initcall\ /,/' | sed 's/\+/,/' | sed 's/returned/,/' | sed 's/after\ /,/' | sed 's/usecs/,/' > aa.log
awk -F "," '{printf("%08d,%s,%s\n", $5, $2, $4)}' aa.log  | sort -r > bb.log 
awk -F "," '{printf("%d,%s,%s\n", $1, $2, $3)}' bb.log > sort_initcall.log
rm -f aa.log bb.log

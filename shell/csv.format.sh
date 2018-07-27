# !/bin/bash

if test $# = 0; then
	echo "Usage:"
	echo "  $0 <input.log>"
	exit
fi

if ! [ -e $1 ]; then
    echo "can not find $1"
    exit
fi

#cp -f in.log _in_.tmp

cp -f $1                                    _in_.tmp
sed -i 's/\ //g'                            _in_.tmp
sed -i 's/备注//g'                          _in_.tmp
sed -i 's/有附件//g'                        _in_.tmp
sed -i 's/kernelK/,K/g'                     _in_.tmp
sed -i 's/kernelM/,M/g'                     _in_.tmp
sed -i 's/MODEM_CRASH/MODEM_CRASH,/g'       _in_.tmp
sed -i 's/KERNEL_PANIC/KERNEL_PANIC,/g'     _in_.tmp

cat _in_.tmp | grep -v "skip,"            > swap.tmp
cat swap.tmp | grep "4.5.0-20180"         > _in_.tmp
cat _in_.tmp | awk -F "," '{ printf("%30s,%12s,%20s,%-30s\n", $1, $2, $3, $4);}' > out.csv

sed -i 's/\(.\{81\}\)/\1,/'                 out.csv
sed -i 's/5\//,5\//'                        out.csv

rm -f *.tmp
cat out.csv

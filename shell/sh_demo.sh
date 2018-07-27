#! /bin/bash

_prefix=`date +%m%d_`
_args=$*
_and_="_"

_postfix=`echo $_args | awk -F "=" '{ print $2}'`
#echo args: $_args
#echo post: $_postfix$_and_

for (( idx=1; idx<100; idx++)); do
	ffnew=$_prefix$idx$_and_$_postfix.mp4
	#echo $ffnew

	if [ ! -e "$ffnew" ]; then
		break
	fi
done

echo output: $ffnew
echo "---.---.---.---" >> ~/youtube_download.log
echo url: $_args >> ~/youtube_download.log
echo out: $ffnew >> ~/youtube_download.log
echo "" >> ~/youtube_download.log

#exit -1
sudo youtube-dl -o $ffnew $*


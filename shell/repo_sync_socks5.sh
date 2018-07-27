#! /bin/bash

#./repo init -u git://github.com/lineage-rpi/android_local_manifest.git -b twrp-8.1
#curl --create-dirs -L -o .repo/local_manifests/manifest_brcm_rpi3.xml -O -L https://raw.githubusercontent.com/lineage-rpi/android_local_manifest/twrp-8.1/manifest_brcm_rpi3.xml
#./repo sync
#
git config --global http.proxy 'socks5://localhost:1080'
git config --global https.proxy 'socks5://localhost:1080'
export http_proxy="socks5://localhost:1080"
export https_proxy="socks5://localhost:1080"

while true; do

	sleep 10
	./repo sync -j32

	if test $? = 0; then
		echo "ret:" $?
		exit 0
	fi

done

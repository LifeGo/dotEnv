#set -x

LINUX_VER="Linux version 4.9.65-perf+ (smartcm@build11) (gcc version 4.9.x 20150123 (prerelease) (GCC) ) #1 SMP PREEMPT Tue Jun 12 21:10:48 CST 2018"

_args=$*
chk_ver=$(echo $_args | grep "Linux version")
if test -z "$chk_ver"; then
	echo "Usage:"
	echo "  $0" "\"$LINUX_VER\""
	exit 0
fi

WORK_DIR=`pwd`
SAMBA_MNT_PATH=mnt
sudo mkdir -p $WORK_DIR/$SAMBA_MNT_PATH

if ! [ -e $WORK_DIR/$SAMBA_MNT_PATH/daily ]; then
	sudo mount -t cifs //172.16.2.240/flash $WORK_DIR/mnt -o domain=smartisan.cn,username=xUser,password=yPassword,vers=1.0
fi

FIND_CGI=http://172.16.2.18/cgi-bin/vmlinux-lookup.cgi
#Linux version
LINUX_VER=$_args
echo $LINUX_VER

# === Kernel
SMB_PATH=$(curl --data-urlencode "version=$LINUX_VER" $FIND_CGI 2>&1 | grep "kernel symbols" -A 1 | tail -1)
SMB_PATH=$(echo $SMB_PATH | sed 's/smb:\/\/172.16.2.240\/flash/'$SAMBA_MNT_PATH'/g')
echo "SMB: " $SMB_PATH
cp -vf $SMB_PATH/vmlinux $WORK_DIR

# === OEM
SMB_PATH=$(curl --data-urlencode "version=$LINUX_VER" $FIND_CGI 2>&1 | grep "OEM symbols" -A 1 | tail -1)
SMB_PATH=$(echo $SMB_PATH | sed 's/smb:\/\/172.16.2.240\/flash/'$SAMBA_MNT_PATH'/g')
echo "SMB: " $SMB_PATH
cp -vf $SMB_PATH/aop_proc/core/bsp/aop/build/AOP_AAAAANAZO.elf $WORK_DIR
cp -vf $SMB_PATH/modem_proc/scripts/bsp/root_pd_img/build/sdm845.gen.prod/MODEM_PROC_IMG_sdm845.gen.prodQ.elf $WORK_DIR
cp -vf $SMB_PATH/trustzone_images/core/bsp/hypervisor/build/WAXAANAA/hyp_stripped.elf $WORK_DIR/hyp.elf
cp -vf $SMB_PATH/trustzone_images/ssg/bsp/qsee/build/WAXAANAA/qsee_stripped.elf $WORK_DIR/qsee.elf
cp -vf $SMB_PATH/trustzone_images/ssg/bsp/monitor/build/WAXAANAA/mon_stripped.elf $WORK_DIR/mon.elf

# === about.html
SMB_PATH=$(curl --data-urlencode "version=$LINUX_VER" $FIND_CGI 2>&1 | grep "Flashing binary" -A 1 | tail -1)
SMB_PATH=$(echo $SMB_PATH | sed 's/smb:\/\/172.16.2.240\/flash/mnt/g')
echo "SMB: " $SMB_PATH
cp -vf $SMB_PATH/about.html $WORK_DIR

# === umount
sudo umount $WORK_DIR/mnt

sudo umount /smbmnt/16/*
sudo umount /smbmnt/17/*
sudo umount /smbmnt/225/*

sudo mkdir -p /smbmnt/16/share
sudo mkdir -p /smbmnt/17/share
sudo mkdir -p /smbmnt/225/flash

sudo mount -t cifs //172.16.2.16/Share  /smbmnt/16/share  -o domain=smartisan.cn,username=username,password=passwd,vers=1.0
sudo mount -t cifs //172.16.2.17/Share  /smbmnt/17/share  -o domain=smartisan.cn,username=username,password=passwd,vers=1.0
sudo mount -t cifs //172.16.2.225/flash /smbmnt/225/flash -o domain=smartisan.cn,username=username,password=passwd,vers=1.0

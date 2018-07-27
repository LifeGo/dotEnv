###
# ubuntu 18.04
###

#-->原来的如下:
#http://ppa.launchpad.net/hzwhuang/ss-qt5/ubuntu bionic main
#-->改成如下:
#http://ppa.launchpad.net/hzwhuang/ss-qt5/ubuntu artful main

sudo rm -f /etc/apt/sources.list.d/hzwhuang-ubuntu-ss-qt5-*.list
sudo add-apt-repository ppa:hzwhuang/ss-qt5

sudo sed -i 's/bionic/artful/' /etc/apt/sources.list.d/hzwhuang-ubuntu-ss-qt5-bionic.list

sudo apt-get update
sudo apt-get install shadowsocks-qt5

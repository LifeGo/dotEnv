mkdir ~/flash

sudo apt update
sudo apt upgrade
sudo apt install vim cscope ctags tree tmux git supervisor openssh-server minicom curl wget axel
sudo apt install samba samba-common
sudo apt install python3.6-pip

pip3 uninstall PyQt5
pip3 install --user PyQt5==5.10.0

sudo cp ./home/.vimrc /etc/vim/vimrc.local
sudo cp ./home/*.vim /usr/share/vim/vim*/plugin -vf

#bash -c "$(curl -s http://172.16.0.9/setup-system-config.sh)" setup-system-config.sh
#sudo apt install android-tools-adb
#fix-usb-permission

sudo service supervisor restart
sudo supervisorctl reload
sudo supervisorctl restart all
# Url: https://apps.evozi.com/apk-downloader/
# Url: https://apkpure.com/



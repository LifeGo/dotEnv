##refurl: "https://dwijaybane.wordpress.com/2017/12/04/oh-my-zsh-and-powerline-fonts-setup-for-awesome-terminal-in-ubuntu-16-04/"

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

sudo cp -vf PowerlineSymbols.otf /usr/share/fonts/
sudo cp -vf 10-powerline-symbols.conf /etc/fonts/conf.d/
sudo fc-cache -vf /usr/share/fonts/


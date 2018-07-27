sudo update-alternatives --remove-all jar
sudo update-alternatives --remove-all java
sudo update-alternatives --remove-all javac
sudo update-alternatives --remove-all javadoc

sudo update-alternatives --install /usr/bin/jar   jar   /usr/lib/jvm/default-java/bin/jar 	3000
sudo update-alternatives --install /usr/bin/java  java  /usr/lib/jvm/default-java/bin/java  3000
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/default-java/bin/javac 3000

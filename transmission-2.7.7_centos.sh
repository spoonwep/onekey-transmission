#!/bin/bash
yum -y install gcc gcc-c++ m4 make automake libtool gettext openssl-devel pkgconfig perl-libwww-perl perl-XML-Parser curl curl-devel libevent-devel libevent libidn-devel zlib-devel 
yum -y upgrade

cd /usr/local/src
wget -c http://lolimilk.com/download/intltool-0.50.2.tar.gz
tar -zxvf intltool-0.50.2.tar.gz
cd intltool-0.50.2
./configure --prefix=/usr
make && make install

cd /usr/local/src
wget -c http://lolimilk.com/download/libevent-2.0.21-stable.tar.gz
tar -zxvf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure && make && make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

echo install Transmisson
cd /usr/local/src
wget -c http://lolimilk.com/download/xz-5.0.4.tar.gz
tar -zxvf xz-5.0.4.tar.gz
cd xz-5.0.4
./configure && make && make install

cd /usr/local/src
wget -c http://lolimilk.com/download/transmission-2.77.tar.xz
xz -d transmission-2.77.tar.xz
tar -xvf  transmission-2.77.tar
cd transmission-2.77
./configure --prefix=/usr
make && make install

useradd -m transmission
passwd -d transmission

wget -O /etc/init.d/transmissiond http://lolimilk.com/download/transmission.sh
chmod 755 /etc/init.d/transmissiond
chkconfig --add transmissiond
chkconfig --level 345 transmissiond on

service transmissiond start
service transmissiond stop

mkdir -p /home/transmission/Downloads/
chown -R transmission.transmission /home/transmission/Downloads/
chmod g+w /home/transmission/Downloads/

wget -c http://lolimilk.com/download/settings_backup.json
mv -f settings_backup.json /home/transmission/.config/transmission/settings.json
service transmissiond start

echo "********************************************************************"
echo "Installation Complete!"
echo "Login: http://yourip:1911"
echo "Default username: admin"
echo "Default password: admin"
echo "Default Download Folder: /home/transmission/Downloads/"
echo "Open this file and change your username & password"
echo "/home/transmission/.config/transmission/settings.json"
echo "********************************************************************"
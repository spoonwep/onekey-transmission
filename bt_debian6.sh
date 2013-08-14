#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## Check user permissions ##
if [ $(id -u) != "0" ]; then
	echo "Error: NO PERMISSION! Please login as root to run this 
script again."
	exit 1
fi

if [ -f /etc/debian_version ]; then
	echo "System information: Debian / Ubuntu (32/64bit)"
	echo ""
	uname -a
	lsb_release -a
	echo ""
else
	echo -e "\033[41;37m Error: script currently only supports Debian 6 (64bit) \033[0m"
	echo ""
	echo "Exiting..."
	echo ""
	exit 1
fi



read -p "Please enter your transmissionrpc password: " trpass
echo ""


read -p "Please enter the rss url(default:none): " rssurl
echo ""

apt-get -y update
apt-get -y install transmission-common transmission-cli transmission-daemon
/etc/init.d/transmission-daemon stop
sed -i '13 s#/var/lib/transmission-daemon/downloads#/home/bt#' /etc/transmission-daemon/settings.json
sed -i '23 s/32/300/' /etc/transmission-daemon/settings.json
sed -i '24 s/240/1000/' /etc/transmission-daemon/settings.json
sed -i '25 s/60/200/' /etc/transmission-daemon/settings.json
sed -i "47 s/{[A-Za-z0-9]\{30,60\}/$trpass/" /etc/transmission-daemon/settings.json
sed -i '49 s/transmission/admin/' /etc/transmission-daemon/settings.json
sed -i '50 s/127.0.0.1/*.*.*.*/' /etc/transmission-daemon/settings.json
sed -i '51 s/true/false/' /etc/transmission-daemon/settings.json
sed -i '63 s/14/14,/' /etc/transmission-daemon/settings.json
sed -i '$d' /etc/transmission-daemon/settings.json
sed -i '64 i\    "watch-dir": "/root/bt",' /etc/transmission-daemon/settings.json
sed -i '65 i\    "watch-dir-enabled": true' /etc/transmission-daemon/settings.json

mkdir /root/bt
mkdir /home/bt
chmod 777 /root/bt
chmod 777 /home/bt

python -V
apt-get install -y python-setuptools
easy_install flexget
mkdir  /root/.flexget
easy_install transmissionrpc
touch  /root/.flexget/config.yml
echo "feeds:" >>/root/.flexget/config.yml
echo "  chinahd:" >>/root/.flexget/config.yml
echo "    rss: $rssurl" >>/root/.flexget/config.yml
echo "    accept_all: yes" >>/root/.flexget/config.yml
echo "    download: /root/bt/" >>/root/.flexget/config.yml


which flexget
/usr/local/bin/flexget --test

cd /root
wget -c http://ogc8.com/file/watch.sh
sed -i "13 s/admin:/admin:$trpass/" watch.sh
chmod 777 watch.sh

touch /var/spool/cron/crontabs/root
echo "*/5 * * * * /usr/local/bin/flexget" >>/var/spool/cron/crontabs/root
echo "*/3 * * * * sh /root/watch.sh" >>/var/spool/cron/crontabs/root
echo "*/10 * * * * find /home/bt/ -mtime +2  -exec rm -rf {} \;" >>/var/spool/cron/crontabs/root
crontab /var/spool/cron/crontabs/root
crontab -l
/etc/init.d/transmission-daemon start

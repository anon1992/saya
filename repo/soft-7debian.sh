#!/bin/bash

#Requirement
if [ ! -e /usr/bin/curl ]; then
    apt-get -y update && apt-get -y upgrade
	apt-get -y install curl
fi

#inisialisasi
MYIP=$(curl -4 icanhazip.com)
if [ $MYIP = "" ]; then
   MYIP=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1`;
fi

cekport=`netstat -ntulp | grep 443 && netstat -ntulp | grep 1194`;
if [ "$cekport" != "" ]; then
		echo "Instalasi Tidak Dapat Dilanjutkan Oleh Sistem";
		echo "Penyebab:";
		echo "Kami mendeteksi port 443 atau port 1194 anda telah terpakai. Pastikan port 443 dan port 1194 anda tidak terpakai.";
		echo "Tutorial mengganti port dropbear dan openvpn dapat anda temukan di blog hostingtermurah.net";
		echo "LOG:";
        echo "==============";
		echo "$cekport";
		echo "==============";
        exit 0;
fi
clear
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
echo "Connecting..."
sleep 0.1
echo "Checking Permision..."
MYIP=$(wget -qO- ipv4.icanhazip.com);

# check registered ip
wget -q -O daftarip http://ssh-top.xyz/daftarip.txt
if ! grep -w -q $MYIP daftarip; then
        echo -e "${red}Permission Denied!${NC}";
        if [[ $vps = "FNS" ]]; then
                echo ""
        else
                echo -e "${red}MAAF IP ANDA BELUM TERDAFTAR ${NC}"
        fi
        rm -f /root/daftarip
        exit
else
echo -e "${green}Permission Accepted...${NC}"
sleep 2.0
fi
clear
# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#Add DNS Server ipv4
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
sed -i '$ i\echo "nameserver 8.8.8.8" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.4.4" >> /etc/resolv.conf' /etc/rc.local


# install wget and curl
apt-get update;apt-get -y install wget curl;

# add repo
cat > /etc/apt/sources.list <<END2
deb http://cdn.debian.net/debian wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb http://packages.dotdeb.org wheezy all
END2
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg

#update
apt-get -y update && apt-get -y upgrade

#install important
apt-get install -y build-essential
apt-get install -y g++ gcc make nano

#install softether
wget http://www.softether-download.com/files/softether/v4.20-9608-rtm-2016.04.17-tree/Linux/SoftEther_VPN_Server/32bit_-_Intel_x86/softether-vpnserver-v4.20-9608-rtm-2016.04.17-linux-x86-32bit.tar.gz
tar -xzvf softether-vpnserver-v4.20-9608-rtm-2016.04.17-linux-x86-32bit.tar.gz
rm -f softether-vpnserver-v4.20-9608-rtm-2016.04.17-linux-x86-32bit.tar.gz
cd vpnserver 
printf '1\n1\n1' | make

#back to root
cd

#move directory
mv vpnserver /usr/local
cd /usr/local/vpnserver/
chmod 600 *
chmod 700 vpncmd
chmod 700 vpnserver


DAEMON='$DAEMON'
LOCK='$LOCK'
VAR0='$0'
VAR1='$1'
syslog='$syslog'
remote_fs='remote_fs'
cat > /etc/init.d/vpnserver <<END
#!/bin/sh
### BEGIN INIT INFO
# Provides:          vpnserver
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable Softether by daemon.
### END INIT INFO
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
test -x $DAEMON || exit 0
case "$VAR1" in
start)
$DAEMON start
touch $LOCK
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
;;
*)
echo "Usage: $VAR0 {start|stop|restart}"
exit 1
esac
exit 0
END
mkdir /var/lock/subsys
chmod 755 /etc/init.d/vpnserver

#start server
/etc/init.d/vpnserver start

#set startup
update-rc.d vpnserver defaults

#cek apakah work
# cd /usr/local/vpnserver
# ./vpncmd
# ketik check . Jika sudah ketik exit.

#Setting
cd /usr/local/vpnserver/
# printf '1\n\n\nServerPasswordSet\nSetup123ScR\nSetup123ScR\n' | ./vpncmd
cd
clear
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "


#Setting di Softether Server Manager
clear
echo "=============================="
echo "Untuk melanjutkan instalasi, anda harus setting melalui SoftEther Server Manager"
echo "Pastikan Anda Telah melakukan semua step di bawah!"
echo "-------------------------------------"
echo "TUTORIAL SETTING LOCAL BRIDGE"
echo "1. Buka SoftEther Server Manager"
echo "2. Klik New Setting."
echo "3. Isikan $MYIP pada kolom Hostname. (Lainnya biarkan default)"
echo "4. Klik OK. Jika sudah tekan tombol CONNECT"
echo "5. Anda akan diminta untuk membuat password administrator softether. Masukkan password yang anda kehendaki."
echo "6. Jika ada window SoftEther Easy Setup, centang Remote Access VPN Server. lalu klik NEXT dan OK"
echo "7. Jika ada window Dynamic DNS Fuction, klik Exit"
echo "8. Jika ada window IPsec/L2TP/EtherIP, centang Enable L2TP Server Functions (L2TP over IPsec)"
echo "9. Jika ada window VPN Azure Service Setting, Klik Disable VPN Azure. Kemudian tekan OK"
echo "10. Jika muncul jendela VPN Easy Setup Task atau Permintaan Update, Close saja"
echo "11. Pada halaman utama SoftEther Server Manager, klik tombol LOCAL BRIDGE SETTING"
echo "12. Pada kolom Virtual Hub, pilih VPN. Kemudian centang tulisan Bridge with New Tap Device"
echo "13. Pada kolom New Tap Device Name, isikan dengan tulisan soft"
echo "14. Klik Create Local Bridge."
echo "15. Pastikan statusnya adalah operating. Jika sudah, close softether server manager"
echo "-------------------------------------"
echo "Jika anda telah menyelesaikan step di atas, tekan sembarang tombol"
echo "=============================="
#Verifikasi 
read -n1 -r -p "Press any key to continue..." key
if [ "$key" = !'' ]; then
    echo "Instalasi Telah Dibatalkan";
fi
echo " "
echo "------------"
echo "Apakah Anda Yakin Telah Menyelesaikan Semua Langkah Di Atas? "
read -n1 -r -p "Jika yakin sudah, tekan sembarang tombol!" key2
if [ "$key2" = !'' ]; then
    echo "Instalasi Telah Dibatalkan";
fi

#cd
apt-get -y install dnsmasq
cat >> /etc/dnsmasq.conf <<END
interface=tap_soft
dhcp-range=tap_soft,192.168.7.50,192.168.7.60,12h
dhcp-option=tap_soft,3,192.168.7.1
END
/etc/init.d/dnsmasq restart


#Setting Iptables
#if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
#    iptables -t nat -A POSTROUTING -o venet0 -j SNAT --to-source $MYIP
#	iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -j SNAT --to-source $MYIP
#	sed  -i '/-A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT/a -A FORWARD -s 192.168.7.0/255.255.255.0 -j ACCEPT' /etc/iptables.up.rules
#	echo 
#   else
#   iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -o eth0 -j MASQUERADE
#	sed  -i '/-A POSTROUTING -o eth0 -j MASQUERADE/a -A POSTROUTING -s 192.168.7.0/24 -o eth0 -j MASQUERADE' /etc/iptables.up.rules
#fi
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -j SNAT --to-source $MYIP
iptables-save > /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local

#Ganti Startup Scriptnya
DAEMON='$DAEMON'
LOCK='$LOCK'
VAR0='$0'
VAR1='$1'
TAP_ADDR='$TAP_ADDR'
syslog='$syslog'
remote_fs='remote_fs'
cat > /etc/init.d/vpnserver <<END
#!/bin/sh
### BEGIN INIT INFO
# Provides: vpnserver
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start daemon at boot time
# Description: Enable Softether by daemon.
### END INIT INFO
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
TAP_ADDR=192.168.7.1

test -x $DAEMON || exit 0
case "$VAR1" in
start)
$DAEMON start
touch $LOCK
sleep 1
/sbin/ifconfig tap_soft $TAP_ADDR
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
sleep 1
/sbin/ifconfig tap_soft $TAP_ADDR
;;
*)
echo "Usage: $VAR0 {start|stop|restart}"
exit 1
esac
exit 0
END
cd
/etc/init.d/vpnserver restart
/etc/init.d/dnsmasq restart
clear

clear
echo "Automatic Script Installer" | tee log-install-softether.txt
echo "===============================================" | tee log-install-softether.txt
echo ""  | tee log-install-softether.txt
echo "Service"  | tee log-install-softether.txt
echo "-------"  | tee log-install-softether.txt
echo "Softehter VPN  : TCP 443, 1194, 555, 992"  | tee log-install-softether.txt
echo "Hostname: $MYIP" | tee log-install-softether.txt
echo "Password : (Sesuai dengan password yang anda input di SoftEther Server Manager)" | tee log-install-softether.txt
echo "==============================================="  | tee log-install-softether.txt
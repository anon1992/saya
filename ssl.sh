#!/bin/bash

#Requirement
if [ ! -e /usr/bin/curl ]; then
    apt-get -y update && apt-get -y upgrade
	apt-get -y install curl
fi
#check jika script sudah pernah diinput
scriptname='sshvpn';
mkdir -p /root/
echo " " >> /root/ssl.txt
scriptchecker=`cat /root/ssl.txt | grep $scriptname`;
if [ "$scriptchecker" != "" ]; then
		clear
		echo -e " ";
		echo -e "Error! Anda sudah pernah memasukkan script ini sebelumnya";
		echo -e "Script ini hanya boleh dimasukkan 1x saja!";
		echo -e "---";
        exit 0;
	else
		echo "";
fi
echo "$scriptname" >> /root/ssl.txt
#inisialisasi
#inisialisasi
MYIP=$(curl -4 icanhazip.com)
if [ $MYIP = "" ]; then
   MYIP=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1`;
fi

cekport=`netstat -ntulp | grep 443 && netstat -ntulp | grep 443`;
if [ "$cekport" != "" ]; then
		echo "Instalasi Tidak Dapat Dilanjutkan Oleh Sistem";
		echo "Penyebab:";
		echo "SSL berjalan pada port 443 , pastikan port 443 tidak terpakai.";
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
wget -q -O https://raw.githubusercontent.com/anon1992/saya/master/daftarip.txt
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

#detail nama perusahaan
country=ID
state=Jakarta
locality=Bekasi
organization=pebayuran
organizationalunit=IT
commonname=pebayuran
email=bustami.naura@gmail.com

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1


[ssh]
accept = 443
connect = 127.0.0.1:22

END

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

#
clear
echo "---------------------------------------"
sleep 2.0
echo "---------------------------------------"
sleep 2.0
echo "Penginstalan SSL selesai" | tee ssl.txt

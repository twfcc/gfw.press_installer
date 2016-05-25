#! /bin/bash
# $author: twfcc@twitter
# $PROG: gfwtiny.sh
# $description: install gfw.press and tinyproxy
# Works on ubuntu 14.04/Debian 7
# gfw.press official site: https://github.com/chinashiyu/gfw.press
# Public Domain use as your own risk!

trap cleanup INT

cleanup(){
	mv -f /etc/tinyproxy.conf.bak /etc/tinyproxy.conf 2> /dev/null ;
	[ -d "$HOME/gfw.press" ] && rm -rf "$HOME/gfw.press" ;
	apt-get remove tinyproxy -y ;
	exit 1 ;
}

[ "$UID" -ne 0 ] && {
	echo "Execute this script must be root." >&2 ;
	exit 1 ;
}

[ $(pwd) != "/root" ] && cd "$HOME"

gfw_press_install() {
	git clone https://github.com/chinashiyu/gfw.press.git ;
	[ $? -eq 0 ] && cd gfw.press || {
		echo "Clone gfw.press failed.exiting..." >&2 ;
		exit 1 ;
	}
	pw=$(genpass)
	port=$(genport)
	echo "$port $pw" > user.txt ;
	cp -f server.sh server.org ;
	sed -i 's/ -Xm[a-z][0-9]\{1,4\}M//g' server.sh ;
	chmod +x server.sh
}

genpass(){
	local i j l u d c count pw
	i=0
	j=1
	u=0
	l=0
	d=0
	pw=$(openssl rand -base64 32 | tr -d '+/0oO' | cut -c3-18)
	count=${#pw}
	while true ; do
		 c=${pw:$i:1}
		[[ "$c" =~ [A-Z] ]] && ((u++))
		[[ "$c" =~ [a-z] ]] && ((l++))
		[[ "$c" =~ [0-9] ]] && ((d++))
		if (($u > 0)) && (($l > 0)) && (($d > 0)) ; then
			break
		fi
		((i++))
		((j++))
		if ((j == count)) ; then
			unset pw i j u l c d count
			local i j u l c d count pw
			i=0
			j=1
			u=0
			l=0
			d=0
			pw=$(openssl rand -base64 32 | tr -d '/+0oO' |cut -c3-18)
			count=${#pw}
		fi
	done
	echo "$pw"
}

genport(){
	local pick count port 
	pick=($(for i in {19901..19999} ;do echo $i ;done))
	count=${#pick[@]}
	port=${pick[$((RANDOM%count-1))]}
	echo "$port"
}

tinyproxy_install(){
	local cfg 
	apt-get install tinyproxy -y
	[ $? -eq 0 ] && cd "/etc" || {
		echo "Install tinyproxy failed." >&2 ;
		exit 1 ;
}
	cfg="tinyproxy.conf"
	[ -f "$cfg" ] && mv -f "$cfg" "${cfg}.bak" 2> /dev/null
	cat >"$cfg"<<EOF
User nobody
Group nogroup
Port 3128
Listen 127.0.0.1
Timeout 600
DefaultErrorFile "/usr/share/tinyproxy/default.html"
StatFile "/usr/share/tinyproxy/stats.html"
Logfile "/var/log/tinyproxy/tinyproxy.log"
LogLevel Connect
PidFile "/var/run/tinyproxy/tinyproxy.pid"
MaxClients 100
MinSpareServers 5
MaxSpareServers 20
StartServers 10
MaxRequestsPerChild 0
Allow 127.0.0.1
ViaProxyName "tinyproxy"
ConnectPort 443
ConnectPort 563

EOF

service tinyproxy restart
cd "$HOME"
}

myip=$(wget -qO - v4.ifconfig.co)
apt-get update && apt-get upgrade -y
apt-get install openssl openjdk-7-jre git -y
tinyproxy_install
gfw_press_install

if netstat -nlp | grep -Eq '^.+127\.0\.0\.1:3128.+tinyproxy' ; then
	echo "Public IP: $myip"
	echo "Port: $port"
	echo "Password: $pw"
	echo ""
	echo "Runing gfw.press by manual,"
	echo "input: gfw.press/server.sh"
	echo "Check gfw.press server status,"
	echo "input: cat gfw.press/server.log"
	echo "or"
	echo "input: netstat -nlp "
	echo ""
	echo "Enjoy"
else
	echo "Install tinyproxy failed." >&2
	cleanup
fi
exit 0

#! /bin/bash
# $Author: twfcc@twitter
# $PROG: gfw3proxy.sh
# $description: install gfw.press & 3proxy 
# Public domain use as your own risk!
# Works on Debian 7/8 and Ubuntu 14.04/15.04

export LANGUAGE=C
export LC_ALL=C
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PATTERN="java -Dfile.encoding=utf-8 -Dsun.jnu.encoding=utf-8 -Duser.timezone=Asia/Shanghai"

trap cleanup INT
[ $(pwd) != /root ] && cd $HOME

[ $UID -ne 0 ] && {
	echo "Execute this script must be root." >&2 ;
	exit 1 ;
}

myip=$(wget -qO - v4.ifconfig.co)

cleanup(){
	kill $(ps aux | grep 3proxy | grep -v grep | awk '{print $2}') 2> /dev/null
	rm -rf "$HOME/3proxy" ;
	rm -rf "$HOME/gfw.press" ;
	rm -rf /usr/local/etc/3proxy/ ;
	update-rc.d -f 3proxyinit remove ;
	rm -f /etc/init.d/3proxyinit ;
	exit 1
}

3proxy_install(){
	git clone https://github.com/z3APA3A/3proxy.git ;
	[ $? -eq 0 ] || {
		echo "Clone 3proxy.git failed.exiting..." >&2 ;
		exit 1 ;
	}
	cd 3proxy/ || {
		echo "Cannot change to 3proxy directory." >&2 ;
		exit 1 ;
	}
	make -f Makefile.Linux ;
	[ $? -eq 0 ] && cd src/ ;
	mkdir -p /usr/local/etc/3proxy/bin/ ;
	install 3proxy /usr/local/etc/3proxy/bin/3proxy ;
	install mycrypt /usr/local/etc/3proxy/bin/mycrypt ;
	touch /usr/local/etc/3proxy/3proxy.cfg ;
	mkdir -p /usr/local/etc/3proxy/log/ ;
	chown -R root:root /usr/local/etc/3proxy/ ;
	chown -R 65535 /usr/local/etc/3proxy/log/ ;
	touch /usr/local/etc/3proxy/3proxy.pid ;
	chown 65535 /usr/local/etc/3proxy/3proxy.pid ;
	local cfg
	cfg="/usr/local/etc/3proxy/3proxy.cfg"
	cat >"$cfg"<<EOF
nscache 65536
nserver 8.8.8.8
timeouts 1 5 30 60 180 1800 15 60
daemon
pidfile 3proxy.pid
config 3proxy.cfg
monitor 3proxy.cfg
log log/3proxy.log D
logformat "L%d-%m-%Y %H:%M:%S %z %N.%p %E %U %C:%c %R:%r %O %I %h %T"
rotate 30
auth none
allow * * * 80-88,8080-8088 
allow * * * 443,8443
allow * * * 5222,5223,5228
allow * * * 465,587,995
proxy -i127.0.0.1 -a -p3128
flush
chroot /usr/local/etc/3proxy/
setgid 65535
setuid 65535

EOF

	cd /etc/init.d/ || {
		echo "Cannot change to /etc/init.d/ directory." >&2 ;
		exit 1 ;
	}
	cat >3proxyinit<<EOF
#! /bin/sh
#
### BEGIN INIT INFO
# Provides: 3Proxy
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Initialize 3proxy server
# Description: starts 3proxy
### END INIT INFO

cd /usr/local/etc/3proxy/
case "\$1" in
	start)  echo "Starting 3Proxy" ;
		/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg
		 ;;
	 stop)  echo "Stopping 3Proxy" ;
		kill \`ps aux | grep 3proxy | grep -v grep | awk '{print \$2}'\`
		;;
	    *)  echo Usage: \\\$0 "{start|stop}" ;
		exit 1 ;
		;;
esac
exit 0

EOF

	if [ -e 3proxyinit ] ; then
		bash -n 3proxyinit > /dev/null 2>&1 ;
		[ $? -eq 0 ] && { 
			chmod +x 3proxyinit ;
			update-rc.d 3proxyinit defaults ;
		} || {
			echo "3proxyinit script is something wrong." >&2 ;
			exit 1 ;
		}
		cd "$HOME" ;
		/etc/init.d/3proxyinit start ;
	else
		echo "3proxyinit script is not exist." >&2 ;
		exit 1
	fi
}

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
	sed -i 's/ -Xm[a-z][0-9]\{1,4\}M//g;s/ >> server\.log/ 2>> \/dev\/null >> \/dev\/null/' server.sh 
	chmod +x server.sh
	./server.sh
	cd $HOME
}

genpass(){
	local i j l u d c count pw
	i=0
	j=1
	u=0
	l=0
	d=0
	pw=$(openssl rand -base64 32 | tr -d '+/0oO=' | cut -c3-18)
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

apt-get update && apt-get upgrade -y 
apt-get install openssl openjdk-7-jre git build-essential libssl-dev -y
3proxy_install
gfw_press_install

if ps aux | grep "$PATTERN" | grep -qv grep && netstat -nlp | grep -q '3proxy'
	then
		echo ""
		echo "Public IP: $myip"
		echo "Port: $port"
		echo "Password: $pw"
		echo ""
		echo "Enjoy"
	else
		echo "Install gfw.press failed. cleaning up .." >&2
		cleanup
fi
exit 0

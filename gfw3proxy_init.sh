#! /bin/bash
# $author: twfcc@twitter
# $PROG: gfw3proxy_init.sh
# $description: Install gfw.press & 3proxy as system service
# $Usage: $0
# Works on Debian 7/8 and Ubuntu 14.04/15.04
# Public domain use as your own risk!

trap cleanup INT

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE=C
export LC_ALL=C
PATTERN="java -Dfile.encoding=utf-8 -Dsun.jnu.encoding=utf-8 -Duser.timezone=Asia/Shanghai"

cleanup(){
	kill $(ps aux | grep 3proxy | grep -v grep | awk '{print $2}') 2> /dev/null
	rm -rf "$HOME/3proxy" 2> /dev/null
	rm -rf /usr/local/etc/gfw.press/ 2> /dev/null
	rm -rf /usr/local/etc/3proxy/ 2> /dev/null
	update-rc.d -f 3proxyinit remove 2> /dev/null
	rm -f /etc/init.d/3proxyinit 2> /dev/null
	update-rc.d -f gfw.press remove 2> /dev/null
	kill -9 $(ps aux | grep "$PATTERN" | grep -v grep | awk '{print $2}') 2> /dev/null
	rm -f /etc/init.d/gfw.press 2> /dev/null
	exit 1
}

[ $UID -ne 0 ] && {
	echo "Execute this script must be root." >&2 
	exit 1 
}

[ $(pwd) != "/root" ] && cd "$HOME"

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
nserver 8.8.4.4
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

gen_pass_matrix(){
	local  matrix i pick pass count j
	matrix=($(for i in {0..9} {a..z} {A..Z} ; do echo "$i" ;done))
	count=${#matrix[@]}
	for (( j=1 ; j<=16 ; j++ )) ;do
		pick=${matrix[$((RANDOM%count-1))]}
		pass="$pass$pick"
	done
	echo "$pass"
}

genpass(){
	local pass lower upper digit 
	pass=$(gen_pass_matrix)

	while true ; do
		lower=${pass//[!a-z]/}
		upper=${pass//[!A-Z]/} 
		digit=${pass//[!0-9]/}

		if [ -n "$lower" ] && [ -n "$upper" ] && [ -n "$digit" ]
			then
				break
			else
				unset pass
				pass=$(gen_pass_matrix)
		fi
	done

	echo "$pass"
}

genport(){
	local pick count port
	pick=($(for i in {19901..19999} ;do echo $i ;done))
	count=${#pick[@]}
	port=${pick[$((RANDOM%count-1))]}
	echo "$port"
}

gfw_press_install(){
	cd /usr/local/etc/ || { 
	echo "Could not change to /usr/local/etc" >&2 ;
	exit 1 ;
	}

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

	cd /etc/init.d/ || {
		echo "Could not change to /etc/init.d " >&2 ;
		exit 1 ;
	}

	cat >gfw.press<<EOF
#! /bin/sh
#
### BEGIN INIT INFO
# Provides: gfw.press
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Initialize gfw.press server
# Description: starts gfw.press
### END INIT INFO

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PATTERN="java -Dfile.encoding=utf-8 -Dsun.jnu.encoding=utf-8 -Duser.timezone=Asia/Shanghai"
PROGNAME=\`basename \$0\`
RETURN_STATUS=
export PATH PATTERN PROGNAME RETURN_STATUS 

do_start(){
	do_status
	cd /usr/local/etc/gfw.press
	if test \$RETURN_STATUS -ne 0 ; then
		_java="java -Dfile.encoding=utf-8 -Dsun.jnu.encoding=utf-8 -Duser.timezone=Asia/Shanghai "
		_java="\${_java}-classpath \`find ./lib/*.jar | xargs echo | sed 's/ /:/g'\`:./bin"
		_pack="press.gfw"
		echo "Strating \$PROGNAME ..."
		nohup \$_java \$_pack.Server 2>> /dev/null >> /dev/null &
	else
		:
	fi
}

do_stop(){
	PIDs=\`ps aux | grep "\$PATTERN" | grep -v grep | awk '{print \$2}'\`
	echo "Stopping \$PROGNAME ..."
	if test "x\$PIDs" != "x" ; then
		kill -9 "\$PIDs"
	else
		echo "\$PROGNAME is not running." >&2
	fi
}

do_restart(){
	do_stop
	do_start
}

do_status(){
	if ps aux | grep "\$PATTERN" | grep -qv grep ; then
		echo "\$PROGNAME is running."
		RETURN_STATUS=0
	else
		echo "\$PROGNAME is not running."
		RETURN_STATUS=1
	fi
}

case "\$1" in
	start) do_start 
		;;
	stop) do_stop  
		;;
	restart) do_restart
		;;
	status) do_status 
		;;
	*) echo "Usage: \$PROGNAME {start|stop|restart|status}" >&2 ; exit 99
		;;
esac
exit 0

EOF

if [ -f "gfw.press" ] ; then
	chmod +x gfw.press ;
	update-rc.d gfw.press defaults ;
else
	echo "gfw.press: no such file or directory." >&2
fi

cd "$HOME"
/etc/init.d/gfw.press start
}

myip=$(wget -qO - v4.ifconfig.co)
apt-get update && apt-get upgrade -y 
apt-get install openssl openjdk-7-jre git build-essential libssl-dev -y
3proxy_install
gfw_press_install

if ps aux | grep "$PATTERN" | grep -qv grep && netstat -nlp | grep -q '3proxy'
	then
		echo "gfw.press is running."
		echo ""
		echo "Public IP: $myip"
		echo "Port: $port"
		echo "Password: $pw"
		echo ""
		echo "Enjoy."
	else
		echo "Install gfw.press failed. cleaning up .." >&2
		cleanup
fi
exit 0

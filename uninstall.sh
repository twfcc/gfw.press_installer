#! /bin/bash
# $author: twfcc@twitter
# $PROG: uninstall.sh
# $description: uninstall components which installed by [gfw3proxy.sh|gfwtiny.sh]
# $Usage: $0
# Public Domain use as your own risk.

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH

[ $(whoami) != "root" ] && {
	echo "Execute this script must be root." >&2
	exit 1
}

[ $(pwd) != "/root" ] && cd "$HOME"

remove_gfw(){
	local pids pattern
	if [ -d "$HOME/gfw.press" ] ; then
		rm -rf "$HOME/gfw.press" 
	fi

	pattern="java -Dfile.encoding=utf-8 -Dsun.jnu.encoding=utf-8 -Duser.timezone=Asia/Shanghai"
	pids=$(ps aux | grep "$pattern" | grep -v grep | awk '{print $2}')

	if [ -n "$pids" ] ; then
		kill $pids
	fi
}

remove_tiny(){
	apt-get purge tinyproxy -y 2> /dev/null
}

remove_3proxy(){
	local pids
	pids=$(ps aux | grep '3proxy' | grep -v grep | awk '{print $2}')
	if [ -n "$pids" ] ; then
		kill "$pids"
	fi
 
	if [ -d "$HOME/3proxy" ] ; then
		rm -rf $HOME/3proxy 
	fi
	if [ -e /etc/init.d/3proxyinit ] ; then
		update-rc.d -f 3proxyinit remove ;
		rm -f /etc/init.d/3proxyinit 2> /dev/null ;
	fi
	if [ -d "/usr/local/etc/3proxy" ] ; then
		rm -rf /usr/local/etc/3proxy ;
	fi
}

printf '%b' '\033[31mUninstall gfw.press\033[39m' 

if which tinyproxy > /dev/null 2>&1
	then 
		remove_gfw
		remove_tiny
	else
		remove_gfw
		remove_3proxy
fi

echo -n " .." ; sleep 1 ; echo -n " .. " ; sleep 1
printf '%b\n' '\033[32mDone.\033[39m'
exit 0


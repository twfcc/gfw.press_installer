# gfw.press_installer

說明

gfw3proxy.sh 是一個bash腳本，安裝gfw.press服務器及後端代理3proxy

gfwtiny.sh 是一個bash腳本，安裝gfw.press服務器及後端代理tinyproxy

gfw3proxy_init.sh 腳本會安裝gfw.press和3proxy,並設置成為系統服務

gfwtiny.sh可在Ubuntu 14.04或Debian 7安裝服務器

gfw3proxy.sh和gfw3proxy_init.sh可在Ubuntu 14.04/15.04或Debian 7/8安裝服務器

只須選擇一個合適的腳本在VPS上安裝服務器

使用方法

以root登錄VPS，執行

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw3proxy.sh

或

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfwtiny.sh

或

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw3proxy_init.sh

chmod +x 腳本名.sh && ./腳本名.sh

如須解除安裝，執行

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/uninstall.sh

chmod +x uninstall.sh && ./uninstall.sh

Explanation

gfw3proxy.sh is a bash script for installing gfw.press and 3proxy

gfwtiny.sh is a bash script for installing gfw.press and tinyproxy

gfw3proxy_init.sh is a bash script for installing gfw.press and 3proxy as system service.

gfwtiny.sh works on Ubuntu 14.04 and Debian 7

gfw3proxy.sh and gfw3proxy_init.sh work on Ubuntu 14.04/15.04 and Debian 7/8

Choose one script only which is suitable for your VPS to install server.

Usage

Login to your VPS as user 'root' via ssh client, follow steps as below

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw3proxy.sh

or

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfwtiny.sh

or

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw3proxy_init.sh

then

chmod +x scriptname && ./scriptname.sh

if you want to uninstall gfw.press and [ tinyproxy | 3proxy ], follow steps as below

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw3proxy_init.sh

chmod +x uninstall.sh && ./uninstall.sh


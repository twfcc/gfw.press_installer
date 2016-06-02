# gfw.press_installer

說明

gfw3proxy.sh 是一個bash腳本，安裝gfw.press服務器及後端代理3proxy

gfwtiny.sh 是一個bash腳本，安裝gfw.press服務器及後端代理tinyproxy

gfw3proxy_init.sh 腳本會安裝gfw.press和3proxy,並設置成為系統服務

gfw.press 是從gfw3proxy_init.sh分拆出來的系統啟動腳本

modify.sh 是shell腳本用來修改gfw.press/server.sh

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

gfw.press系統啟動腳本主要是非使用gfw3proxy_init.sh安裝服務器，而又須要設置系統啟動gfw.press

以root登錄VPS，執行

1) mkdir -p /usr/local/etc/

2) cd /usr/local/etc

3) git clone https://github.com/chinashiyu/gfw.press.git

4) cd gfw.press 

5) cp server.sh server.bak

6) wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/modify.sh

7) chmod +x modify.sh server.sh

8) ./modify.sh server.sh

9) cd /etc/init.d/

10) wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw.press

11) chmod +x gfw.press

12) 如果是Debian Base OS用戶，執行

    update-rc.d gfw.press defaults 
    
    /etc/init.d/gfw.press start
    
    如果是CentOS/RedHat Base OS 用戶，請參考
    
    https://support.suso.com/supki/CentOS_Init_startup_scripts
    
    https://blog.sleeplessbeastie.eu/2012/07/07/centos-how-to-manage-system-services/
    
    或須要修改gfw.press系統啟動腳本

Explanation

gfw3proxy.sh is a bash script for installing gfw.press and 3proxy

gfwtiny.sh is a bash script for installing gfw.press and tinyproxy

gfw3proxy_init.sh is a bash script for installing gfw.press and 3proxy as system service.

gfw.press is a system init script coming from gfw3proxy_init.sh part of codes

modify.sh is  a shell script for modify gfw.press/server.sh

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

wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/uninstall.sh

chmod +x uninstall.sh && ./uninstall.sh

gfw.press system init script for install gfw.press and components not by gfw3proxy_init.sh script,who needs 
to start gfw.press server and service automatically while system startup.

Login to your vps with user 'root' via ssh client,follow steps as below

1) mkdir -p /usr/local/etc/

2) cd /usr/local/etc

3) git clone https://github.com/chinashiyu/gfw.press.git

4) cd gfw.press 

5) cp server.sh server.bak

6) wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/modify.sh

7) chmod +x modify.sh server.sh

8) ./modify.sh server.sh

9) cd /etc/init.d/

10) wget --no-check-certificate https://raw.githubusercontent.com/twfcc/gfw.press_installer/master/gfw.press

11) chmod +x gfw.press

12) For Debian Base OS users ,input command as below

    update-rc.d gfw.press defaults
    
    /etc/init.d/gfw.press start
    
    For CentOS/RedHat Base OS users, please visit source as below for more details.
    
    https://support.suso.com/supki/CentOS_Init_startup_scripts
    
    https://blog.sleeplessbeastie.eu/2012/07/07/centos-how-to-manage-system-services/
    
    It is possible to modify gfw.press system init script to fit the system

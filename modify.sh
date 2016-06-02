#! /bin/sh 

sed -i 's/ -Xm[a-z][0-9]\{1,4\}M//g;s/ >> server\.log/ 2>> \/dev\/null >> \/dev\/null/' "$*" 

#! /bin/bash
# $author: twfcc@twitter
# $PROG: safepw.sh
# $description: password generator for gfw.press
# $Usage : $0 8-99 ,default length 16 if argument is not given
# Public Domain use as your own risk
#
##################################################################
# rule of gfw.press password requirment:                         #
# 1) length at least 8,                                          #
# 2) 1 or more uppercase letter, 1 or more lowercase letter and  #
#    1 or more digit number must be included                     #
##################################################################

howmany=${1:-16}
password_gen(){
        local matrix pw count pick i
        matrix="123456789aAbBcCdDeEfFgGhHiIjJkKLmMnNpPqQrRsStTuUvVwWxXyYzZ"
        count="${#matrix}"
        for ((i=1 ; i<=howmany ;i++)) ; do
                pick=${matrix:$((RANDOM%count-1)):1}
                pw="$pw$pick"
        done
        echo "$pw"
}

case "$howmany" in
                8|9) ;;
         [1-9][0-9]) ;;
                  *) echo "Usage: $0 8-99" >&2
                     echo "Default length: 16 if no argument is given." >&2
                     exit 1
                    ;;
esac

pass=$(password_gen)
while true ; do
        lower=${pass//[!a-z]/}
        upper=${pass//[!A-Z]/}
        digit=${pass//[!0-9]/}
        if [ -n "$lower" ] && [ -n "$upper" ] && [ -n "$digit" ]
                then
                        break
                else
                        unset pass
                        pass=$(password_gen)
        fi
done

echo "$pass"


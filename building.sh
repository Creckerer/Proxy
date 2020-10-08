#!/bin/bash
. configs
#Install dependencies
if ! apt install -y git curl build-essential libssl-dev zlib1g-dev ; then
 echo "Need to use SUDO"
exit 1
fi
#-------------------------------------------------------------
cd $servdir
#Clone the repo
git clone https://github.com/TelegramMessenger/MTProxy
 cd $servdir/MTProxy || { echo "Path ./MTProxy isn't exist"; exit 1; }
#Building
if ! make ; then
echo "Proxy didn't make" 
make clean
exit 1
 else echo "Proxy made" 
fi
#---------------------------------------------------------------
cd $servdir/MTProxy/objs/bin || { echo "Path ./objs/bin isn't exist"; exit 1; }
curl -s https://core.telegram.org/getProxySecret -o $servdir/MTProxy/objs/bin/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o $servdir/MTProxy/objs/bin/proxy-multi.conf
./mtproto-proxy -u $userNM -p $lport -H $uport -S "$secret" \
                          --aes-pwd proxy-secret proxy-multi.conf -M $works \
                           || { echo "XXXX"; exit 1; }
#---------------------------------------------------------------
# Systemd configuration
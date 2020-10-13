#!/bin/bash
. configs
#Install dependencies
cd /opt/ || { echo "Path /opt/ isn't exist"; exit 1; }
if ! apt install -y git curl build-essential libssl-dev zlib1g-dev cron-apt ; then
 echo "Need to use SUDO"
exit 1
fi
#-------------------------------------------------------------
cd /opt/
#Clone the repo
git clone https://github.com/TelegramMessenger/MTProxy
 cd /opt/MTProxy || { echo "Path /opt/MTProxy isn't exist"; exit 1; }
#Building
if ! make ; then
echo "Proxy didn't make" 
make clean
exit 1
 else echo "Proxy made" 
fi
#---------------------------------------------------------------
cd /opt/MTProxy/objs/bin || { echo "Path /opt/MTProxy/objs/bin isn't exist"; exit 1; }
curl -s https://core.telegram.org/getProxySecret -o /opt/MTProxy/objs/bin/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /opt/MTProxy/objs/bin/proxy-multi.conf
#/opt/MTProxy/objs/bin/mtproto-proxy -u $userNM -p $lport -H $uport -S "$secret" \
   #                       --aes-pwd proxy-secret proxy-multi.conf -M $works \
    #                       || { echo "Proxy start failed"; exit 1; }
#---------------------------------------------------------------
#creating cron rule
touch /etc/cron.daily/autoproxydaily
chmod 755 /etc/cron.daily/autoproxydaily
echo "
\#!/bin/bash
curl -s https://core.telegram.org/getProxySecret -o /opt/MTProxy/objs/bin/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /opt/MTProxy/objs/bin/proxy-multi.conf" > /etc/cron.daily/autoproxydaily
#---------------------------------------------------------------
# Systemd configuration
touch /etc/systemd/system/MTProxy.service || { echo "Oooops some problem with creating a file MTProxy.service"; exit 1; }
chmod 664 /etc/systemd/system/MTProxy.service
echo "[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/MTProxy/objs/bin/
ExecStart=/opt/MTProxy/objs/bin/mtproto-proxy -u $userNM -p $lport -H $uport -S "$secret" \
 --aes-pwd proxy-secret proxy-multi.conf -M $works
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/MTProxy.service
#---------------------------------------------------------------
#starting service
systemctl daemon-reload
systemctl restart MTProxy.service
systemctl status MTProxy.service || { echo "Oooops some problem with MTProxy.service"; exit 1; }
systemctl enable MTProxy.service
#---------------------------------------------------------------

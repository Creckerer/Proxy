#!/bin/bash
. configs
START_DIR=($PWD)
#Clone the repo

cd $DIR_TO_INSTALL || { echo "Path isn't exist"; exit 1; }
git clone https://github.com/TelegramMessenger/MTProxy
 cd $DIR_TO_INSTALL/MTProxy || { echo "Path isn't exist"; exit 1; }
#Building
[[ -e "$DIR_TO_INSTALL/MTProxy/objs/bin/mtproto-proxy" ]] && systemctl stop MTProxy.service  && make clean && echo "CLEAN!"
if ! make ; then
echo "Proxy didn't make" 
make clean
exit 1
 else echo "Proxy made" 
fi
#---------------------------------------------------------------
cd $DIR_TO_INSTALL/MTProxy/objs/bin || { echo "Path  isn't exist"; exit 1; }
curl -s https://core.telegram.org/getProxySecret -o $DIR_TO_INSTALL/MTProxy/objs/bin/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o $DIR_TO_INSTALL/MTProxy/objs/bin/proxy-multi.conf
#---------------------------------------------------------------
#creating cron rule
[[ ! -e "/etc/cron.daily/autoproxydaily" ]] && echo "#!/bin/bash
cd $START_DIR
./building_finish " > /etc/cron.daily/autoproxydaily && \
chmod 755 /etc/cron.daily/autoproxydaily  && echo "CRON CREATED"
#---------------------------------------------------------------
# Systemd configuration
  [[ ! -e "etc/systemd/system/MTProxy.service" ]] && \
  sed -i "s|\$DIR_TO_INSTALL|$DIR_TO_INSTALL|g" "$START_DIR"/MTProxy.service.inst && \
  sed -i "s|\$USER_NM|$USER_NM|g" "$START_DIR"/MTProxy.service.inst && \
  sed -i "s|\$L_PORT|$L_PORT|g" "$START_DIR"/MTProxy.service.inst && \
  sed -i "s|\$USR_PORT|$USR_PORT|g" "$START_DIR"/MTProxy.service.inst && \
  sed -i "s|\$SECRET|$SECRET|g" "$START_DIR"/MTProxy.service.inst && \
  sed -i "s|\$WORKS|$WORKS|g" "$START_DIR"/MTProxy.service.inst && \
 # touch /etc/systemd/system/MTProxy.service && \
  cp "$START_DIR/MTProxy.service.inst" /etc/systemd/system/MTProxy.service && \
  chmod 664 /etc/systemd/system/MTProxy.service && \
  echo "SERVICE CREATED"

 # echo "[Unit]
#Description=MTProxy
#After=network.target

#[Service]
#Type=simple
#WorkingDirectory=$DIR_TO_INSTALL/MTProxy/objs/bin/
#ExecStart=$DIR_TO_INSTALL/MTProxy/objs/bin/mtproto-proxy -u $USER_NM $L_PORT -H $USR_PORT -S "$SECRET" \
# --aes-pwd proxy-secret proxy-multi.conf -M $WORKS
#Restart=on-failure

#[Install]
#WantedBy=multi-user.target" > /etc/systemd/system/MTProxy.service && chmod 664 /etc/systemd/system/MTProxy.service && \
#echo "SERVICE CREATED"
#---------------------------------------------------------------
#starting service
systemctl daemon-reload
systemctl restart MTProxy.service
systemctl status MTProxy.service || { echo "Problem with MTProxy.service"; exit 1; }
systemctl enable MTProxy.service
#---------------------------------------------------------------

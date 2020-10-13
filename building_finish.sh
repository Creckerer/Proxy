#!/bin/bash
. configs
START_DIR="$PWD"
#Clone the repo
cd $DIR_TO_BUILD || { echo "Path isn't exist"; exit 1; }
git clone https://github.com/TelegramMessenger/MTProxy
 cd $DIR_TO_BUILD/MTProxy || { echo "Path isn't exist"; exit 1; }
#Building
[[ -e "$DIR_TO_INSTALL/mtproto-proxy" ]] && systemctl stop MTProxy.service && echo "SERVICE WAS STOPPED!"
if ! make ; then
echo "Proxy didn't make" 
make clean
systemctl start MTProxy.service
exit 1
 else echo "Proxy made" 
fi
mkdir "$DIR_TO_INSTALL" && cp "$DIR_TO_BUILD/MTProxy/objs/bin/mtproto-proxy" "$DIR_TO_INSTALL/mtproto-proxy" \
 || { echo "Problem with installation"; exit 1; }
#---------------------------------------------------------------
cd $DIR_TO_INSTALL
curl -s https://core.telegram.org/getProxySecret -o $DIR_TO_INSTALL/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o $DIR_TO_INSTALL/proxy-multi.conf
#---------------------------------------------------------------
#creating cron rule
[[ ! -e "/etc/cron.daily/autoproxydaily" ]] && echo "#!/bin/bash
cd $START_DIR
./building_finish " > /etc/cron.daily/autoproxydaily && \
chmod 755 /etc/cron.daily/autoproxydaily  && echo "CRON CREATED"
#---------------------------------------------------------------
# Systemd configuration
  cp "$START_DIR"/MTProxy.service.inst "$DIR_TO_BUILD"/MTProxy
  [[ ! -e "etc/systemd/system/MTProxy.service" ]] && \
  sed -i "s|\$DIR_TO_INSTALL|$DIR_TO_INSTALL|g" "$DIR_TO_BUILD"/MTProxy/MTProxy.service.inst && \
  sed -i "s|\$USER_NM|$USER_NM|g" "$DIR_TO_BUILD"/MTProxy/MTProxy.service.inst && \
  sed -i "s|\$L_PORT|$L_PORT|g" "$DIR_TO_BUILD"/MTProxy/MTProxy.service.inst && \
  sed -i "s|\$USR_PORT|$USR_PORT|g" "$DIR_TO_BUILD"/MTProxy/MTProxy.service.inst && \
  sed -i "s|\$SECRET|$SECRET|g" "$DIR_TO_BUILD"/MTProxy/MTProxy.service.inst && \
  sed -i "s|\$WORKS|$WORKS|g" "$DIR_TO_BUILD"/MTProxy/MTProxy.service.inst && \
  cp "$DIR_TO_BUILD/MTProxy/MTProxy.service.inst" /etc/systemd/system/MTProxy.service && \
  chmod 664 /etc/systemd/system/MTProxy.service && \
  echo "SERVICE CREATED"
#---------------------------------------------------------------
#starting service
systemctl daemon-reload
systemctl restart MTProxy.service
systemctl status MTProxy.service || { echo "Problem with MTProxy.service"; exit 1; }
systemctl enable MTProxy.service
#---------------------------------------------------------------

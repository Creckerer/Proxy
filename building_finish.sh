#!/bin/bash
. configs
START_DIR="$PWD"
if [ -d "$DIR_TO_BUILD/MTProxy" ]; then
  cd "$DIR_TO_BUILD/MTProxy"
  git pull
else
  mkdir "$DIR_TO_BUILD"
  cd "$DIR_TO_BUILD"
  git clone "https://github.com/TelegramMessenger/MTProxy"
  cd "$DIR_TO_BUILD/MTProxy" || \
    { echo "Path isn't exist"; exit 1; }
fi
#---------------------------------------------------------------
#Building
if ! make; then
  echo "BUILD CRASHED"
  make clean
  exit 1
else
  echo "BUILD DONE"
fi
#---------------------------------------------------------------
if [ -e "$DIR_TO_INSTALL/mtproto-proxy" ]; then
  systemctl stop MTProxy.service
  echo "SERVICE STOPPED FOR A LITTLE"
  cp "$DIR_TO_BUILD/MTProxy/objs/bin/mtproto-proxy" "$DIR_TO_INSTALL/mtproto-proxy"
else
  mkdir "$DIR_TO_INSTALL"
  cp "$DIR_TO_BUILD/MTProxy/objs/bin/mtproto-proxy" "$DIR_TO_INSTALL/mtproto-proxy"
fi
#---------------------------------------------------------------
if [ -e "$DIR_TO_INSTALL/proxy-secret" ] && [ -e "$DIR_TO_INSTALL/proxy-multi.conf" ]; then
  [ ! -d "$DIR_TO_INSTALL/MTProxy_install_bak" ] && \
    mkdir "$DIR_TO_INSTALL/MTProxy_install_bak"
  [ -d "$DIR_TO_INSTALL/MTProxy_install_bak" ] && \
    cp "$DIR_TO_INSTALL/proxy-secret" "$DIR_TO_INSTALL/MTProxy_install_bak" && \
    cp "$DIR_TO_INSTALL/proxy-multi.conf" "$DIR_TO_INSTALL/MTProxy_install_bak"
elif [ ! -e "$DIR_TO_INSTALL/proxy-secret" ] || [ ! -e "$DIR_TO_INSTALL/proxy-multi.conf" ]; then
  curl -s https://core.telegram.org/getProxySecret -o "$DIR_TO_INSTALL/proxy-secret" && \
    curl -s https://core.telegram.org/getProxyConfig -o "$DIR_TO_INSTALL/proxy-multi.conf" || \
    echo "CHECK CONFIG FILES"
fi
#---------------------------------------------------------------
#creating cron rule
if [ ! -e "/etc/cron.daily/autoproxydaily" ]; then
  cp "$START_DIR/cron_autoproxydaily" "$DIR_TO_BUILD"
  sed -i "s|START_DIR|$START_DIR|g" "$DIR_TO_BUILD/cron_autoproxydaily" && \
    sed -i "s|NAME_OF_SCRIPT|$0|g" "$DIR_TO_BUILD/cron_autoproxydaily" || \
    echo "CHECK CRON RULE"
  cp "$DIR_TO_BUILD/cron_autoproxydaily" "/etc/cron.daily/autoproxydaily" || \
    echo "CHECK CRON RULE"
  chmod 755 "/etc/cron.daily/autoproxydaily"
  echo "CRON CREATED"
fi
#---------------------------------------------------------------
# Systemd configuration
if [ ! -e "etc/systemd/system/MTProxy.service" ]; then
  cp "$START_DIR/MTProxy.service.inst" "$DIR_TO_BUILD"
  sed -i "s|DIR_TO_INSTALL|$DIR_TO_INSTALL|g" "$DIR_TO_BUILD/MTProxy.service.inst" && \
    sed -i "s|USER_NM|$USER_NM|g" "$DIR_TO_BUILD/MTProxy.service.inst" && \
    sed -i "s|L_PORT|$L_PORT|g" "$DIR_TO_BUILD/MTProxy.service.inst" && \
    sed -i "s|USR_PORT|$USR_PORT|g" "$DIR_TO_BUILD/MTProxy.service.inst" && \
    sed -i "s|SECRET|$SECRET|g" "$DIR_TO_BUILD/MTProxy.service.inst" && \
    sed -i "s|WORKS|$WORKS|g" "$DIR_TO_BUILD/MTProxy.service.inst" && \
    cp "$DIR_TO_BUILD/MTProxy.service.inst" "/etc/systemd/system/MTProxy.service" && \
    chmod 664 "/etc/systemd/system/MTProxy.service" && \
    echo "SERVICE CREATED"
fi
#---------------------------------------------------------------
#starting service
systemctl daemon-reload
systemctl restart MTProxy.service
systemctl status MTProxy.service || \
  { echo "Problem with MTProxy.service"; exit 1; }
systemctl enable MTProxy.service
#---------------------------------------------------------------

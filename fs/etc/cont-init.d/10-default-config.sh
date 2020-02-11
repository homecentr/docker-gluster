#!/usr/bin/with-contenv bash

CURRENT_USER=$(whoami)

echo '
    __  __                                     __
   / / / /___  ____ ___  ___  ________  ____  / /______
  / /_/ / __ \/ __ `__ \/ _ \/ ___/ _ \/ __ \/ __/ ___/
 / __  / /_/ / / / / / /  __/ /__/  __/ / / / /_/ /    
/_/ /_/\____/_/ /_/ /_/\___/\___/\___/_/ /_/\__/_/     
'
echo "
-------------------------------------
User uid:    $(id -u $CURRENT_USER)
User gid:    $(id -g $CURRENT_USER)
-------------------------------------
"

if ls -1qA /etc/glusterfs | grep -q .
then
  echo "/etc/glusterfs is not empty, skipping defaulting..."
else
  echo "/etc/glusterfs is empty, copying default configuration..."

  cp -R /etc/glusterfs-default/. /etc/glusterfs/
fi
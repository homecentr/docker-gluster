#!/usr/bin/env bash

CONTAINER_NAME="glusterfs"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root/sudo"
  exit
fi

if [ ! "$(system-docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "glusterfs container does not exist, please enable and start the glusterfs service"
else
    if [ ! "$(system-docker ps -aq -f status=running -f name=$CONTAINER_NAME)" ]; then
        echo "glusters service is not running, please start it using sudo ros s up glusterfs"
    else
        system-docker exec -it glusterfs gluster $@
    fi
fi
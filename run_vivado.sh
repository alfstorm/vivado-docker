#!/bin/sh
# Runs Vivado and cleans up when done.
docker run --rm -ti -e DISPLAY=$DISPLAY -e HOST_USER_ID=`id -u` -e HOST_USER_GID=`id -g` --privileged -v /dev/bus/usb:/dev/bus/usb -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/developer/.Xauthority -v $HOME/docker-share/vivado:/home/developer astorm/buster-vivado-2020.1


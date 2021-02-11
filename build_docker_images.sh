#!/bin/sh
# These Dockerfiles require docker v1.9 or greater
# I invoke docker with sudo to remind me that it's
# running as root. USR pulls back out the actual invokers
# user name.

DIR="$PWD"

# --- Configure Here ---
MAINTAINER="Alf Storm <astorm@nevion.com>"
BASE_IMAGE_NAME="astorm/buster-vivado-base:latest"
XV_IMAGE_NAME="astorm/buster-vivado-2020.1:latest"
# share path will reside inside user's HOME folder
XV_SHARE_PATH=docker-share/vivado

# Populate the docker files with the config
sed "s|@maintainer@|$MAINTAINER|" \
    "$DIR"/Buster-Vivado-Base/Dockerfile.in > \
    "$DIR"/Buster-Vivado-Base/Dockerfile
sed -e "s|@maintainer@|$MAINTAINER|" \
    -e "s|@buster-base-image@|$BASE_IMAGE_NAME|" \
    "$DIR"/Buster-Vivado-2020.1/Dockerfile.in >\
    "$DIR"/Buster-Vivado-2020.1/Dockerfile

# Now build the base image
cd "$DIR"/Buster-Vivado-Base
docker build -t "$BASE_IMAGE_NAME" .

if [ $? -ne 0 ]; then
    echo ERROR: Failed to build base image.
    exit 1
fi

echo Base image built. Building final image...
cd "$DIR"/Buster-Vivado-2020.1
docker build -t "$XV_IMAGE_NAME" .

if [ $? -ne 0 ]; then
  echo ERROR: Failed to build final image.
  exit 1
fi

echo Done.

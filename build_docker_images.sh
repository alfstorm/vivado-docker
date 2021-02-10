#!/bin/sh
# These Dockerfiles require docker v1.9 or greater
# I invoke docker with sudo to remind me that it's
# running as root. USR pulls back out the actual invokers
# user name.

DIR="$PWD"
USR=$(ls -l $(tty) | awk '{print $3}')

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
docker build --build-arg b_uid=`id -u $USR` \
    --build-arg b_gid=`id -g $USR` \
    -t "$BASE_IMAGE_NAME" .

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

XV_IMG_SNAME=`echo $XV_IMAGE_NAME | sed "s|[:].*||"`

echo Creating the run script
cd "$DIR"
# Create the run vivado script
cat << EOF > run_vivado.sh
#!/bin/sh
# Runs Vivado and cleans up when done.
docker run --rm -ti -e DISPLAY=\$DISPLAY \
-e HOST_USER_ID=\`id -u\` -e HOST_USER_GID=\`id -g\` \
--privileged -v /dev/bus/usb:/dev/bus/usb \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v \$HOME/.Xauthority:/home/developer/.Xauthority \
-v \$HOME/$XV_SHARE_PATH:/home/developer \
$XV_IMG_SNAME

EOF

#Fixup file ownership
chown $USR:$USR run_vivado.sh
chmod +x run_vivado.sh

echo Done.

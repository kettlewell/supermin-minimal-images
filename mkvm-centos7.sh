#!/bin/bash
#
# This script will create a minimal centos image that is
# good for things like docker ( which is what I made this for )
#
# In order to build an image using this script, you *must* run
# the script from a CentOS 7 machine in order to build a CentOS 7 image.
#
# Once your image is built, you can import it into docker,
# and run it as a docker container

set -e

if [ "$(id -u)" -eq "0" ]; then
    echo "Run As Regular User"
    exit 1
fi

# Update packages to taste...
# pkgs="yum coreutils bash iputils iproute epel-release"

pkgs="yum coreutils bash"


SUPERMIN=''

if command -v supermin5 >/dev/null 2>&1; then
    SUPERMIN=$(command -v supermin5)

elif command -v supermin >/dev/null 2>&1; then
    SUPERMIN=$(command -v supermin)
else
    echo "supermin not found. Exiting."
    exit 1
fi

echo "supermin found as ${SUPERMIN}"

BASE_DIR=$(pwd)
echo "Base Directory: ${BASE_DIR}"

cd $BASE_DIR

echo "Removing old directories"
rm -rf supermin.d  centos7-zero.tar

# Not sure why I need sudo for this...
sudo rm -rf appliance.d

echo "Running Supermin Prepare with these packages:  ${pkgs}"
/usr/bin/supermin5 --prepare ${pkgs} -o supermin.d

echo "Running Supermin Build"
/usr/bin/supermin5 --build --format chroot supermin.d -o appliance.d

# Never found a good reason as to *WHY* releasever doesn't get set right...
echo "manually setting releasever and basearch"

for repo in $(find ${BASE_DIR}/appliance.d/etc/yum.repos.d -name "*.repo" -type f);
do
    echo ${repo}
    sed -i 's/$releasever/7/g' ${repo}
    sed -i 's/$basearch/x86_64/g' ${repo}
done

echo "Removing Unwanted Locales"
mv appliance.d/usr/share/locale/en appliance.d/tmp
mv appliance.d/usr/share/locale/en_US appliance.d/tmp
rm -rf appliance.d/usr/share/locale/*
mv appliance.d/tmp/en  appliance.d/usr/share/locale/
mv appliance.d/tmp/en_US  appliance.d/usr/share/locale/

echo "Tarring up the image"
tar --numeric-owner -Jcpf ${BASE_DIR}/centos7-zero.tar.xz -C ${BASE_DIR}/appliance.d .

echo "Image Size of ${BASE_DIR}/centos7-zero.tar.xz:  $(ls -h ${BASE_DIR}/centos7-zero.tar.xz)"
echo "Importing image into Docker"
xzcat ${BASE_DIR}/centos7-zero.tar.xz | sudo docker import - local/centos7-zero

# Move this to it's own run.sh script
sudo docker run -i -t local/centos7-zero /bin/bash

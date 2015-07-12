#!/bin/bash

apt-get --yes update
apt-get --yes upgrade
apt-get --yes dist-upgrade

# If we are compiling....
apt-get --yes -qq install gcc make bc screen ncurses-dev
apt-get --yes -qq install automake

#-------------------------------------------------#
#              Raspberry PI Kernel                #
#-------------------------------------------------#
KERNEL_VERSION_MAJOR=$(uname -r | cut -d '.' -f1)
KERNEL_VERSION_MINOR=$(uname -r | cut -d '.' -f2)

# Delete the kernel zip file if exists
if [ -f "/usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz" ]; then
  rm -f /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz
fi

# Download the kernel from github
wget https://github.com/raspberrypi/linux/archive/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz -O /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz
if [ $? -ne 0 ]; then
  echo "Error: Unable to download the kernel"
  exit 1
fi

# Unzip
cd /usr/src
tar -zxvf rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip
if [ $? -ne 0 ]; then
  if [ -d "/usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y" ]; then
    rm -rf /usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y
  fi
  if [ -f "/usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz" ]; then
    rm -f /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz
  fi
  
  echo "Error: Unable to download the kernel"
  exit 1
fi
  
# Delete zip file
if [ -f "/usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz" ]; then
  rm -f /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.tar.gz
fi

if [ -d "/usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y" ]; then
  echo "Error: could not find the kernel source path"
  exit 1
fi
  
mv /usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y /usr/src/linux
ln -s /usr/src/linux /lib/modules/$(uname -r)/build


cd /usr/src/linux
make mrproper
if [ $? -ne 0 ]; then
  echo "Error: failed to run ' make mrproper'"
  exit 1
fi

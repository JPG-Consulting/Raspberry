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
if [ -f "/usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip" ]; then
  rm -f /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip
fi

# Download the kernel from github
if [ ! -d "/usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y" ]; then
  wget https://github.com/raspberrypi/linux/archive/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip -O /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip
  if [ $? -ne 0 ]; then
    echo "Error: Unable to download the kernel"
    exit 1
  fi

  # Unzip
  cd /usr/src
  unzip rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip
  if [ $? -ne 0 ]; then
    if [ -d "/usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y" ]; then
      rm -rf /usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y
    fi
    if [ -f "/usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip" ]; then
      rm -f /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip
    fi
    
    echo "Error: Unable to download the kernel"
    exit 1
  fi
  
  # Delete zip file
  if [ -f "/usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip" ]; then
    rm -f /usr/src/rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y.zip
  fi
  
  if [ -d "/usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y" ]; then
    echo "Error: could not find the kernel source path"
    exit 1
  fi
  
  export KERNEL_SRC=/usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y
fi

cd /usr/src/linux-rpi-$KERNEL_VERSION_MAJOR.$KERNEL_VERSION_MINOR.y
make mrproper
if [ $? -ne 0 ]; then
  echo "Error: failed to run ' make mrproper'"
  exit 1
fi

#-------------------------------------------------#
#                3G USB chan_dongle               #
#-------------------------------------------------#
cd /usr/src

if [ -f /usr/src/asterisk-chan-dongle.zip ]; then
  rm -f /usr/src/asterisk-chan-dongle.zip
fi

wget https://github.com/bg111/asterisk-chan-dongle/archive/master.zip -O /usr/src/asterisk-chan-dongle.zip
if [ $? -ne 0 ]; then
  echo "Error: Unable to download asterisk-chan-dongle"
  exit 1
fi

unzip asterisk-chan-dongle.zip

cd /usr/src/asterisk-chan-dongle-master

aclocal && autoconf && automake -a

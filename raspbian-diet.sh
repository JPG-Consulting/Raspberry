#!/bin/bash

# Install deborphan
apt-get --yes -qq deborphan

apt-get --yes -qq purge xserver*
apt-get --yes -qq purge ^x11
apt-get --yes -qq purge ^libx

apt-get --yes -qq purge lxde*

apt-get --yes autoremove
apt-get --yes clean

# Use deborphan to remove orphaned packages
apt-get --yes --purge remove `deborphan | tr "\n" " "`

# Remove deborphan
apt-get --yes --q deborphan dialog

# Just in case we run again clean up
apt-get --yes autoremove
apt-get --yes clean

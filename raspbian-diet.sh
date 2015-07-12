#!/bin/bash

apt-get --yes -qq purge xserver*
apt-get --yes -qq purge ^x11
apt-get --yes -qq purge ^libx

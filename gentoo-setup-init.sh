#!/bin/bash

source /etc/profile

# Portage Configure Set
CORES=`grep processor /proc/cpuinfo | wc -l`
cat <<EOF > /etc/portage/make.conf
# These settings were set by the catalyst build script that automatically built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more detailed example.
COMMON_FLAGS="-O2 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"
LDFLAGS="\${LDFLAGS} -Wl,--undefined-version"

# NOTE: This stage was built with the bindist Use flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8

# autounmask-write disable protects
CONFIG_PROTECT_MASK="/etc/portage/package.accept_keywords/zzz.keywords /etc/portage/package.use/zzz.use"

# add option autounmask-write and continue
EMERGE_DEFAULT_OPTS="--autounmask-write=y --autounmask-license=y --autounmask-continue=y --with-bdeps=y --verbose-conflicts --verbose --quiet-build"

# Add Compile Option
MAKEOPTS="-j $CORES"

# Video Chip Setting
VIDEO_CARDS="amdgpu radeon"

# Accepted Licanse
ACCEPT_LICENSE="* -@EULA google-chrome"

# Accepted Keywords
ACCEPT_KEYWORDS="~amd64"

# Mirror Setting
GENTOO_MIRRORS="http://ftp.iij.ad.jp/pub/linux/gentoo/ https://ftp.jaist.ac.jp/pub/Linux/Gentoo/ http://ftp.jaist.ac.jp/pub/Linux/Gentoo/ https://ftp.riken.jp/Linux/gentoo/ http://ftp.riken.jp/Linux/gentoo/"

# Platform Setting
GRUB_PLATFORMS="efi-64"

# Language Setting
L10N="ja"
EOF

# Repositories Sync
emerge-webrsync

# Need eclean
emerge app-portage/gentoolkit

# GIT Install
emerge dev-vcs/git

# Generate Locale JP
echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set 4
source /etc/profile

# Timezone Setting
echo "Asia/Tokyo" > /etc/timezone
emerge --config sys-libs/timezone-data

# DHCP Service Setup
emerge sys-apps/mlocate net-misc/dhcpcd
rc-update add dhcpcd default

# NTPD Setting
emerge net-misc/chrony
cat <<EOF > /etc/chrony/chrony.conf
# Use public NTP servers from the pool.ntp.org project.
pool ntp.nict.jp iburst

# In first three updates step the system clock instead of slew
# if the adjustment is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

hwclockfile /etc/adjtime
EOF

# Chronyd Booted Start
rc-update add chronyd default

# ESelect Repository Enable
emerge eselect-repository

# KDE Repository Add
eselect repository enable kde

# Original Profile Add
eselect repository add custom_profile git https://github.com/KotoishiHeart/khcustomprofile/

# Gentoo Repository Setup
rm -rf /var/db/repos/gentoo
eselect repository enable gentoo

# Add Repository Setup
eselect repository enable kde
eselect repository enable guru
eselect repository enable qt
eselect repository enable catalyst

# Repositories Sync
emerge --sync
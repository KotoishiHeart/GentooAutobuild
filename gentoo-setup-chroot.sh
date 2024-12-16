#!/bin/bash

# In ChRoot
source /etc/profile

# Repositories Sync
emerge-webrsync

# Portage Configure Set
CORES=`grep processor /proc/cpuinfo | wc -l`
JOBS=`bc <<< "scale=0; 10*((0.8*${CORES})+0.5)/10;"`
cat <<EOF > /etc/portage/make.conf
# These settings were set by the catalyst build script that automatically built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more detailed example.
COMMON_FLAGS="-O2 -march=znver4 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"

# NOTE: This stage was built with the bindist Use flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8

# autounmask-write disable protects
CONFIG_PROTECT_MASK="/etc/portage/package.accept_keywords/zzz.keywords /etc/portage/package.use/zzz.use"

# add option autounmask-write and continue
EMERGE_DEFAULT_OPTS="--autounmask-write=y --autounmask-license=y --autounmask-continue=y --with-bdeps=y --verbose-conflicts --verbose --quiet-build"

# Add Compile Option
MAKEOPTS="-j $JOBS"

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
eselect repository enable gentoo

# Add Repository Setup
eselect repository enable kde
eselect repository enable guru
eselect repository enable qt
eselect repository enable catalyst

# Repositories Sync
emaint sync --repo custom_profile
emaint sync --repo kde
emaint sync --repo guru
emaint sync --repo qt
emaint sync --repo catalyst

# System Upgrade
emerge --update --deep --newuse --changed-deps=y --with-bdeps=y @world

# Custom Profile Set
cd /etc/portage/
rm make.profile
ln -s ../../var/db/repos/custom_profile/profiles/default/linux/amd64/23.0/no-multilib/desktop/plasma make.profile

# Change no-multilib desktop profile
emerge --update --deep --newuse --changed-deps=y --with-bdeps=y @world

# Setup KDE Desktop
emerge plasma-meta kde-apps-meta

# Setup Japanese Input Methods
emerge media-fonts/fonts-meta media-fonts/kochi-substitute media-fonts/vlgothic media-fonts/mplus-outline-fonts media-fonts/sazanami

# Display Manager Setting
cat <<EOF > /etc/conf.d/display-manager
CHECKVT=7
DISPLAYMANAGER="sddm"
EOF

# Display Manager Enable
rc-update add display-manager default

# Other Application
emerge mail-client/thunderbird

# Google Chrome Install
emerge www-client/google-chrome

# EPSON Printer Driver
emerge net-print/cups-meta

# CUPS Daemon Enable
rc-update add cupsd default

# Firmware Install
emerge sys-kernel/linux-firmware

# Kernel Install 
emerge sys-kernel/installkernel
emerge sys-kernel/gentoo-sources

# Grub Setup
emerge sys-boot/grub os-prober
cat <<EOF >> /etc/default/grub
GRUB_DISABLE_OS_PROBER=false
EOF

# Make Gentoo User
useradd -m -G users,wheel,audio,cdrom,video -s /bin/bash gentoo
emerge app-admin/sudo

# Setting Autostart
mkdir -p /home/gentoo/.config/autostart/
cp /var/tmp/*.desktop /home/gentoo/.config/autostart/
chown gentoo:gentoo -R /home/gentoo/.config/autostart/

rm -rf /varr/db/repos/gentoo
emerge --sync

# System Upgrade
emerge --update --deep --newuse --changed-deps=y --with-bdeps=y @world

# CleanUp
emerge --depclean
eclean --deep distfiles
eclean --deep packages

find /var/tmp/portage/ -maxdepth 2
rm -rf /var/tmp/portage/*
rm -rf /var/cache/distfiles/*
rm -rf /var/cache/binpkgs/*
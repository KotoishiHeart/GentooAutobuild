#!/bin/bash

source /etc/profile

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
cat /var/tmp/patches/sudo_nopasswd.patch | patch -u /etc/sudoers

# Setting Autostart
mkdir -p /home/gentoo/.config/autostart/
cp /var/tmp/*.desktop /home/gentoo/.config/autostart/

chown gentoo:gentoo -R /home/gentoo.config/autostart/

# System Upgrade
emerge --update --deep --newuse --changed-deps=y --with-bdeps=y @world
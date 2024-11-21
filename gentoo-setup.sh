#!/bin/bash

GENTOO_TARBALL_MIRROR_ROOT=http://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/
GENTOO_TARBALL_LASTEST=`curl ${GENTOO_TARBALL_MIRROR_ROOT}latest-stage3-amd64-llvm-openrc.txt --silent | grep stage | cut -d' ' -f 1`

# User Script Copy
mkdir -p /mnt/gentoo/usr/local/bin/
mkdir -p /mnt/gentoo/var/tmp/
mkdir -p /mnt/gentoo/etc/portage/package.accept_keywords/
mkdir -p /mnt/gentoo/etc/portage/package.use/
cp gentoo-setup-chroot.sh /mnt/gentoo/
cp myscripts/* /mnt/gentoo/usr/local/bin/
cp --parents patches/sudo_nopasswd.patch /mnt/gentoo/var/tmp/
cp --parents autostart/* /mnt/gentoo/var/tmp/
cp -R portage/* /mnt/gentoo/etc/portage/

# UnPackage
cd /mnt/gentoo/
wget ${GENTOO_TARBALL_MIRROR_ROOT}${GENTOO_TARBALL_LASTEST}
# Stage Tarball UnPackage
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
# Resolv.conf Copy
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
# Autowrite File
touch /mnt/gentoo/etc/portage/package.accept_keywords/zzz.keywords
touch /mnt/gentoo/etc/portage/package.use/zzz.use
# Add Run Permission
chmod a+x ./gentoo-setup-chroot.sh
chmod a+x ./usr/local/bin/*
# Mount System Point
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --rbind /run /mnt/gentoo/run
mount --make-rslave /mnt/gentoo/run
mkdir -p /mnt/gentoo/run/udev
mount -o bind /run/udev /mnt/gentoo/run/udev
mount --make-rslave /mnt/gentoo/run/udev
# Setup Start
chroot /mnt/gentoo /gentoo-setup-chroot.sh

echo "Setup Complete"

# Cleanup
rm ./stage3-*.tar.*
rm ./gentoo-setup-chroot.sh

# Package
tar -cvJf ../stage3-amd64-llvm-openrc-`date '+%Y%m%dT%H%M%SZ'`.tar.xz *
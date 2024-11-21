#!/bin/bash

source /etc/profile

# Custom Profile Set
cd /etc/portage/
rm make.profile
ln -s ../../var/db/repos/custom_profile/profiles/default/linux/amd64/23.0/no-multilib/llvm/desktop/plasma make.profile

# Change no-multilib desktop profile
emerge --update --deep --newuse --changed-deps=y --with-bdeps=y --backtrack=50 @world

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
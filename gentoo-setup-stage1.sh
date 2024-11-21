#!/bin/bash

source /etc/profile

# Custom Profile Set
cd /etc/portage/
rm make.profile
ln -s ../../var/db/repos/custom_profile/profiles/default/linux/amd64/23.0/no-multilib/llvm make.profile

# Change multilib to no-multilib for profile
emerge --emptytree --usepkg=n @system
emerge @preserved-rebuild
#!/bin/bash

source /etc/profile

# CleanUp
emerge --depclean
eclean --deep distfiles
eclean --deep packages

find /var/tmp/portage/ -maxdepth 2
rm -rf /var/tmp/portage/*
rm -rf /var/cache/distfiles/*
rm -rf /var/cache/binpkgs/*
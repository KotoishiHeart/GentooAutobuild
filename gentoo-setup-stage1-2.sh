#!/bin/bash

source /etc/profile

emerge --emptytree --usepkg=n --exclude 'sys-devel/gcc*' @world
emerge @preserved-rebuild
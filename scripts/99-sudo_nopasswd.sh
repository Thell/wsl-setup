#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/99-sudo-nopasswd-all.sh

then call your install scripts and disable using:
sudo rm -f /etc/sudoers.d/SUDO_NOPASSWD_ALL

//NOTES//

echo "%sudo ALL = NOPASSWD: ALL" > "/etc/sudoers.d/SUDO_NOPASSWD_ALL"

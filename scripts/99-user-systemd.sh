#!/usr/bin/env bash

: <<\#*************************************************************************

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/99-user-systemd.sh

It will setup systemd. After doing this scripts that will make use of the
systemd environment will need to login using the primary $USER for the
init to take place meaning at least 1 'sudo' response or a NOPASSWD clause
for doing sudo commands.

#*************************************************************************

cd /tmp
URL=$(wsl-proxied-url ubuntu-wsl2-systemd-script)
curl -kL ${URL} --output - | tar zxvf -
cd ./ubuntu-wsl2-systemd-script-master/
bash ./ubuntu-wsl2-systemd-script.sh

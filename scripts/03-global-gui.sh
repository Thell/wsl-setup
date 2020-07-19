#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/11-common-gui.sh

It will
 - setup cascadia code availability.
 - install basic X libs.

//NOTES//

### Cascadia Code ttf font for GUI apps.
# Mounting the full Windows font dir can slow down some app startup times.
cd /tmp
URL=https://api.github.com/repos/microsoft/cascadia-code/releases/latest
URL=$(curl ${URL} | grep download_url | cut -d\" -f4)
FONT_DIR="/usr/local/share/fonts/truetype/cascadia"
mkdir -p ${FONT_DIR}
curl -L -o cascadia-code.zip ${URL}
unzip cascadia-code.zip ttf/*.ttf -d ${FONT_DIR}
eatmydata apt -y install fontconfig

# packages=(
#   ### APT Setup
#   # With recommends.
# )
# eatmydata apt -y --no-install-recommends install ${packages[@]}

# packages=(
#   ### APT Setup
#   # Without recommends.
# )
# eatmydata apt -y --no-install-recommends install ${packages[@]}

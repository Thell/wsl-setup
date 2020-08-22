#!/usr/bin/env bash

: <<\#*************************************************************************

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/03-global-gui.sh

It will
- setup cascadia code.
- setup firacode.
- setup emoji font support.

* Avoid mounting the Windows font dir; it slows down some app startup times.

#*************************************************************************

cd /tmp
FONT_DIR="/usr/local/share/fonts/truetype"

mkdir -p ${FONT_DIR}/cascadia-code
wget -q -O cascadia-code.zip $(wsl-proxied-url cascadia-code)
unzip -q cascadia-code.zip ttf/*.ttf -d ${FONT_DIR}/cascadia-code

mkdir -p ${FONT_DIR}/firacode
wget -q -O firacode.zip $(wsl-proxied-url firacode)
unzip -q firacode.zip variable_ttf/*.ttf -d ${FONT_DIR}/firacode

# Manually configure FiraCode spacing for RStudio.
mkdir -p /etc/fonts/conf.d
cat > /etc/fonts/conf.d/90-firacode-spacing.conf << \EOL
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="scan">
    <test name="family">
      <string>Fira Code</string>
    </test>
    <edit name="spacing">
      <int>100</int>
    </edit>
  </match>
</fontconfig>
EOL

export DEBIAN_FRONTEND=noninteractive
packages=(
  fonts-noto-color-emoji
  fontconfig
  ttf-bitstream-vera
)
eatmydata apt-get -y install ${packages[@]}

#!/bin/bash
. ./scripts/99-nexus-translate.sh

: << '//NOTES//'
  Execute this script from Windows as root:
  wsl -d Ubuntu -u root -- ./scripts/03-global-gui.sh

  It will
  - setup cascadia code.
  - setup firacode.
  - setup emoji font support.

  * Avoid mounting the Windows font dir; it slows down some app startup times.
//NOTES//

cd /tmp
FONT_DIR="/usr/local/share/fonts/truetype"

mkdir -p ${FONT_DIR}/cascadia-code
wget -q -O cascadia-code.zip $(nexus_cascadiacode_latest)
unzip -q cascadia-code.zip ttf/*.ttf -d ${FONT_DIR}/cascadia-code

mkdir -p ${FONT_DIR}/firacode
wget -q -O firacode.zip $(nexus_firacode_latest)
unzip -q firacode.zip ttf/*.ttf -d ${FONT_DIR}/firacode

# Manually configure FiraCode spacing for RStudio.
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
  fonts-ubuntu-console
  fontconfig
  ttf-bitstream-vera
)
eatmydata apt-get -y install ${packages[@]}

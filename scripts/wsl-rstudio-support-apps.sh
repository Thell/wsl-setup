#!/usr/bin/env bash

: <<\#*************************************************************************
 
Execute this script from Windows as user:
wsl -d Ubuntu -u root -- ./scripts/wsl-rstudio-support-apps.sh

It will setup
  - mathjax (with 3rd party contributions) for rmarkdown
  - meld
  - openJDK (default-jdk)
  - pandoc for rmarkdown
  - wsl-open for wsl interop

#*************************************************************************

SCRIPT_PATH=$(readlink --canonicalize --no-newline "${BASH_SOURCE%/*}")
cd ~

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

packages=(
  default-jdk
  equivs
  freeglut3
  libnss3
  meld
  perl-tk
  xdg-utils
)
apt-get -y --no-install-recommends install ${packages[@]}

# TinyTex install prep, holds TexLive installs.
cd /tmp
equivs-build ${SCRIPT_PATH}/texlive-local.txt
dpkg -i ./texlive-local_*.deb

# Rmarkdown install prep.
wget -O pandoc.deb $(wsl-proxied-url pandoc)
gdebi -n ./pandoc.deb

MATHJAX_DIR=/usr/local/lib/mathjax
mkdir -p ${MATHJAX_DIR}
mkdir -p ${MATHJAX_DIR}/contrib
wget -O mathjax.tar.gz $(wsl-proxied-url mathjax)
wget -O mathjax-contrib.tar.gz $(wsl-proxied-url mathjax-third-party-extensions)
tar -C ${MATHJAX_DIR} --strip-components 1 -zxf mathjax.tar.gz
tar -C ${MATHJAX_DIR}/contrib --strip-components 1 -zxf mathjax-contrib.tar.gz

# Open via Windows Interop.
curl -o /usr/local/bin/wsl-open $(wsl-proxied-url wsl-open)
chmod 755 /usr/local/bin/wsl-open

# RMarkdown Output Types (web types added in 'user' setup script).
cat > /usr/local/etc/mailcap << \EOF
application/vnd.openxmlformats-officedocument.wordprocessingml.document; wsl-open '%s'
application/pdf; wsl-open '%s'
EOF

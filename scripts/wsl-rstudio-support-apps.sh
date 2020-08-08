#!/bin/bash
. ./scripts/99-nexus-translate.sh
cp ./scripts/texlive-local.txt ~/texlive-local.txt

: << '//NOTES//'

Execute this script from Windows as user:
wsl -d Ubuntu -u root -- ./scripts/wsl-rstudio-support-apps.sh

It will setup
  - mathjax (with 3rd party contributions) for rmarkdown
  - meld
  - openJDK (default-jdk)
  - pandoc for rmarkdown
  - wsl-open for wsl interop

//NOTES//

export DEBIAN_FRONTEND=noninteractive

apt update
apt -y upgrade

packages=(
  default-jdk
  equivs
  freeglut3
  libnss3
  meld
  perl-tk
  xdg-utils
)
apt install -y --no-install-recommends ${packages[@]}

# TinyTex install prep, holds TexLive installs.
cd /tmp
equivs-build ~/texlive-local.txt
dpkg -i ./texlive-local_*.deb

# Rmarkdown install prep.
wget -q -O pandoc.deb $(nexus_pandoc_latest_amd64)
gdebi -n ./pandoc.deb

mkdir -p /usr/local/lib/mathjax/contrib
wget -q -O mathjax.tar.gz $(nexus_mathjax_latest)
wget -q -O mathjax-contrib.tar.gz $(nexus_mathjax_3rd_party_latest)
tar -C /usr/local/lib/mathjax/ --strip-components 1 -zxf mathjax.tar.gz
tar -C /usr/local/lib/mathjax/contrib --strip-components 1 -zxf mathjax-contrib.tar.gz

# Open via Windows Interop.
curl -o /usr/local/bin/wsl-open https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
chmod 755 /usr/local/bin/wsl-open

# RMarkdown Output Types (web types added in 'user' setup script).
cat > /usr/local/etc/mailcap << \EOF
application/vnd.openxmlformats-officedocument.wordprocessingml.document; wsl-open '%s'
application/pdf; wsl-open '%s'
EOF

#!/bin/bash
. ./scripts/99-nexus-translate.sh

: << '//NOTES//'

Execute this script from Windows as user:
wsl -d Ubuntu -u root -- ./scripts/wsl-rstudio-system.sh

It will
  - setup R
  - RStudio Desktop Preview
- configure RStudio to use
  - System Pandoc
  - System Mathjax

Installing devtools and tidyverse gives more common packages than I need
for general purpose scripting and basic package dev...

//NOTES//

### R Install
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
apt-add-repository "deb http://localhost:8081/repository/focal-cran-4.0-proxy focal-cran40/"

packages=(
  libcurl4-gnutls-dev
  libssh2-1-dev
  libssl-dev
  libxml2-dev
  littler
  r-base
)
apt install -y ${packages[@]}

ln -s /usr/lib/R/site-library/littler/examples/build.r /usr/local/bin/build.r
ln -s /usr/lib/R/site-library/littler/examples/check.r /usr/local/bin/check.r
ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r
ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r
ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r
ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r
ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r
chgrp 1000 /usr/local/lib/R/site-library

RPROFILE_SITE=/etc/R/Rprofile.site
cat >> ${RPROFILE_SITE} << \EOF

# Use RStudio Package Manager Binaries, try nexus proxy repository first.
local({
    r <- getOption("repos")
    r["CRAN"] <- "http://localhost:8081/repository/focal-rspm-4.0-binary/"
    r["RSPM"] <- "https://packagemanager.rstudio.com/all/__linux__/focal/latest"
    options(repos = r)
    options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))
})
EOF

# R system packages.
packages=(
  devtools
  docopt
  microbenchmark
  RcppArmadillo
  tidyverse
  tinytest
)
install.r ${packages[@]%,}

RENVIRON_SITE=/etc/R/Renviron.site
cat >> ${RENVIRON_SITE} << \EOF

# Honor $XDG_
R_ENVIRON_USER=${XDG_CONFIG_HOME}/R/Renviron
R_PROFILE_USER=${XDG_CONFIG_HOME}/R/Rprofile

# dir needs to be created on a user level.
R_LIBS_USER=${XDG_LIB_HOME}'/R/%p-library/%v'

# Using non-secure nexus repository to secure download.
RSTUDIO_DISABLE_SECURE_DOWNLOAD_WARNING=1

# Tell RStudio to use system pandoc and mathjax.
RMARKDOWN_MATHJAX_PATH=/usr/local/lib/mathjax
RSTUDIO_PANDOC=/usr/bin

# Use nexus proxy for tinytex
TINYTEX_DIR=${XDG_LIB_HOME}/TinyTeX
CTAN_REPO=http://localhost:8081/repository/texlive/tlnet
EOF

### RStudio Install
cd /tmp
wget -q -O rstudio.deb $(nexus_rstudio_latest_amd64)
gdebi -n ./rstudio.deb
ln -s /usr/lib/rstudio/bin/rstudio /usr/local/bin/rstudio

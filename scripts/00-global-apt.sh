#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/02-global-apt.sh

It will
 - setup apt-cache-ng proxy detection.
 - setup tmpfs .deb extraction usage.
 - install some common tools used when downloading and installing packages.

//NOTES//
### apt-cacher-ng proxy
# To use this manually setup docker desktop with wsl2 with
# - https://github.com/sameersbn/docker-apt-cacher-ng
# - docker volume create apt-cacher-ng
# - docker compose (pin the image with a tag)
WSL_PROXYTEST_PATH="/usr/sbin/wsl-apt-proxy"
cat > ${WSL_PROXYTEST_PATH} << \EOF
#!/bin/bash

# Executed as part of apt.conf.d/00-wsl-apt-proxy

#!/bin/bash
WSL_HOST_IP=$(ip r l default | cut -d\  -f3)
nc -w1 -z ${WSL_HOST_IP} 3142 && \
  echo "http://${WSL_HOST_IP}:3142" || \
  echo "DIRECT"

EOF
chmod +x ${WSL_PROXYTEST_PATH}

WSL_PROXYCONF_PATH="/etc/apt/apt.conf.d/00-wsl-apt-proxy"
cat > ${WSL_PROXYCONF_PATH} << EOF
Acquire::http::Proxy-Auto-Detect "${WSL_PROXYTEST_PATH}";
EOF

DEB_EXTRACT_PATH=/dev/shm/apt/TempDir
DEB_EXTRACTCONF_PATH="/etc/apt/apt.conf.d/00-wsl-deb-extract"
cat > ${DEB_EXTRACTCONF_PATH} << EOF
APT::ExtractTemplates::TempDir "${DEP_EXTRACT_PATH}";
DPkg {
  Pre-Invoke  { "mkdir -p ${DEB_EXTRACT_PATH}" };
  Post-Invoke { "rm -rf ${DEB_EXTRACT_PATH}" };
};
EOF

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

apt -qq update
apt -yq --with-new-pkgs upgrade &>/dev/null
apt -qq update
apt -yq install eatmydata &>/dev/null

packages=(
  ### APT Setup
  # Without recommends.
  apt-transport-https
  aria2
  build-essential
  dialog
  gdebi-core
  httpie
  jq
  libarchive-tools
  libnss3
  libxml2
  unzip
  xml2
)
eatmydata apt -yqq --no-install-recommends install ${packages[@]} &>/dev/null

URL=https://api.github.com/repos/EricChiang/pup/releases/latest
RE_PATTERN="browser_download_url.*linux_amd64"
URL=$(curl -sS ${URL} | grep ${RE_PATTERN} | cut -d\" -f4)
ZIP_PATH=${XDG_TMP_DIR}/pup.zip
curl -sSL -o ${ZIP_PATH} ${URL}
unzip -qq -d /usr/local/bin/ ${ZIP_PATH}

#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/02-global-apt.sh

It will
 - setup /tmp as tmpfs (persists on exit, clears on vm shutdown).
 - setup tmpfs apt archives via /tmp.
 - setup tmpfs .deb extraction via /dev/shm.
 - setup apt-cache-ng proxy detection.
 - install some common tools used when downloading and installing packages.

//NOTES//

WSL_APTLANGUAGE_PATH="/etc/apt/apt.conf.d/00-wsl-apt-language"
cat > ${WSL_APTLANGUAGE_PATH} << EOF
Acquire::Languages "none";
EOF

### Setup tmpfs tmp path
echo "tmpfs /tmp tmpfs mode=1777,nosuid,nodev 0 0"  >> /etc/fstab
mount -a

WSL_APTCACHE_PATH="/tmp"
WSL_APTCACHECONF_PATH="/etc/apt/apt.conf.d/00-wsl-apt-cache"
cat > ${WSL_APTCACHECONF_PATH} << EOF
DIR::CACHE::ARCHIVES "${WSL_APTCACHE_PATH}";
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

### apt-cacher-ng proxy
# Manually setup and start apt-cacher-ng in separate distro.
WSL_PROXYTEST_PATH="/usr/sbin/wsl-apt-proxy"
cat > ${WSL_PROXYTEST_PATH} << \EOF
#!/bin/bash

# Executed as part of apt.conf.d/00-wsl-apt-proxy

#!/bin/bash
WSL_HOST_IP=localhost

exec 9<>/dev/tcp/${WSL_HOST_IP}/3142
STATUS=$?
exec 9>&-
if [ "X$STATUS" = "X0" ]; then
  echo "http://${WSL_HOST_IP}:3142"
else
  echo "DIRECT"
fi

EOF
chmod +x ${WSL_PROXYTEST_PATH}

WSL_PROXYCONF_PATH="/etc/apt/apt.conf.d/00-wsl-apt-proxy"
cat > ${WSL_PROXYCONF_PATH} << EOF
Acquire::http::Proxy-Auto-Detect "${WSL_PROXYTEST_PATH}";
EOF

apt update
apt -y install eatmydata 
eatmydata apt -y --with-new-pkgs upgrade
apt update

packages=(
  ### APT Setup
  # Without recommends.
  aria2
  build-essential
  ca-certificates
  curl
  dialog
  gdebi-core
  git
  gnupg
  httpie
  jq
  software-properties-common
  unzip
  wget
  xdg-user-dirs
)
eatmydata apt -y --no-install-recommends install ${packages[@]}

cd /tmp
URL=https://api.github.com/repos/EricChiang/pup/releases/latest
RE_PATTERN="browser_download_url.*linux_amd64"
URL=$(curl ${URL} | grep ${RE_PATTERN} | cut -d\" -f4)
ZIP_PATH=/tmp/pup.zip
curl -L -o ${ZIP_PATH} ${URL}
unzip -d /usr/local/bin/ ${ZIP_PATH}

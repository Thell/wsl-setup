#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/00-install-global-profile.sh

It will:
 - setup locale
 - setup /tmp as tmpfs so that /tmp persists on exit and re-entry
   and clears on vm shutdown/restarts.
 - add a global profile to
   - create /run/user/${UID} at login
   - export environment variables for $XDG_* paths and create the paths.
   - export gui support environmental variables.

If systemd is active then this script shouldn't be used.
`systemctl enable tmp.mount` enabled tmp on tmpfs, it already handles
runtime dir setup and provides cleaner ways to setup environment variables.

//NOTES//

### Locale
locale-gen en_US.UTF-8
/usr/sbin/update-locale LANG=en_US.UTF-8

### Setup tmpfs tmp path
echo "tmpfs /tmp tmpfs mode=1777,nosuid,nodev 0 0"  >> /etc/fstab

### Runtime dir
MKRUNUSERDIR_PATH="/usr/sbin/wsl-user-mk-runuserdir"
cat > ${MKRUNUSERDIR_PATH} << \EOF
# Executed as part of 00-wsl-user-env.sh
RUNUSER_DIR="/run/user"
UID=$(id -u ${SUDO_USER})
sudo mkdir -m 0700 -p ${RUNUSER_DIR}/${UID}
sudo chown ${UID}:${UID} ${RUNUSER_DIR}/${UID}

EOF
chmod +x ${MKRUNUSERDIR_PATH}
echo "%sudo ALL = NOPASSWD: ${MKRUNUSERDIR_PATH}" >\
  "/etc/sudoers.d/$(basename wsl-user-mk-runuserdir)"

### Global Profile
cat > /etc/profile.d/00-wsl-user-env.sh << \EOF
### XDG Paths
# Create global XDG_ path ENV variables.
set -a
XDG_BIN_DIR="${HOME}/.local/bin"
XDG_CACHE_HOME="${HOME}/.local/var/cache"
XDG_CONFIG_HOME="${HOME}/.local/etc"
XDG_DATA_HOME="${HOME}/.local/share"
XDG_LIB_HOME="${HOME}/.local/lib"
XDG_LOG_HOME="${HOME}/.local/var/log"
XDG_PROJECTS_DIR="$HOME/Projects"
XDG_RUNTIME_DIR="/run/user/${UID}"
XDG_SRC_DIR="${HOME}/.local/src"
XDG_STATE_HOME="${HOME}/.local/var/lib"
XDG_TMP_DIR="${XDG_RUNTIME_DIR}/tmp"
set +a
sudo /usr/sbin/wsl-user-mk-runuserdir

# Create XDG dirs.
if [[ ! -f "${XDG_CONFIG_HOME}/user-dirs.dirs" ]]
then
  mkdir -p \
    ${XDG_BIN_DIR} \
    ${XDG_CACHE_HOME} \
    ${XDG_CONFIG_HOME} \
    ${XDG_DATA_HOME} \
    ${XDG_LIB_HOME} \
    ${XDG_LOG_HOME} \
    ${XDG_PROJECTS_DIR} \
    ${XDG_SRC_DIR} \
    ${XDG_STATE_HOME} \
    ${XDG_TMP_DIR}
  ln -sfn ${XDG_TMP_DIR} .local/tmp

  xdg-user-dirs-update
  xdg-user-dirs-update --set "BIN" ${XDG_BIN_DIR}
  xdg-user-dirs-update --set "PROJECTS" ${XDG_PROJECTS_DIR}
  xdg-user-dirs-update --set "SRC" ${XDG_SRC_DIR}
  xdg-user-dirs-update --set "TMP" ${XDG_TMP_DIR}
fi

set -a
source "${XDG_CONFIG_HOME}/user-dirs.dirs"

### Global GUI app support ENV.
DISPLAY="$(ip r l default | cut -d\  -f3):0.0"
GDK_SCALE="1.2"
NO_AT_BRIDGE="1"
QT_SCALE_FACTOR="1.2"
QT_X11_NO_MITSHM="1"
set +a

EOF

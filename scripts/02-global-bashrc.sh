#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u root -- ./scripts/01-install-global-bashrc.sh

It will
 - setup global powerline-go prompt.

//NOTES//

### powerline-go with wsl machine name segment.
URL=https://api.github.com/repos/thell/powerline-go/releases
URL=$(curl ${URL} | grep download_url | cut -d\" -f4)
curl -L ${URL} | tar -vxz -C /usr/local/bin

cat >> /etc/bash.bashrc << \EOL
### Powershell-go
# `User` segment when not WSL default user.
# Only use hostname if ssh.
function _update_ps1() {
  if [ "${USER}" == "thell" ]; then
    PL_MODULES='wsl,venv,host,ssh,cwd,perms,jobs,git,exit,root'
  else
    PL_MODULES='wsl,venv,user,host,ssh,cwd,perms,jobs,git,exit,root'
  fi
  PS1="$(powerline-go -modules ${PL_MODULES} -hostname-only-if-ssh -error $?)"
}

if [ "$TERM" != "linux" ] && [ -x "$(command -v powerline-go)" ]; then
  PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

EOL

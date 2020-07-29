#!/bin/bash

: << '//NOTES//'

Execute this script from Windows as root:
wsl -d Ubuntu -u $USER -- ./scripts/11-user-bash.sh

It will
- setup git

//NOTES//

# Git setup
USER_NAME=$(git.exe config user.name)
USER_EMAIL=$(git.exe config user.email)
CRED_MGR="/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"

git config --global credential.helper "${CRED_MGR}"
git config --global user.name "${USER_NAME}";
git config --global user.email "${USER_EMAIL}";
git config --global alias.last 'log -1 HEAD';
git config --global alias.unstage 'reset HEAD --';
git config --global alias.co checkout;
git config --global alias.br branch;
git config --global alias.ci commit;
git config --global alias.st status

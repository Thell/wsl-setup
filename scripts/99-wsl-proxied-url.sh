#!/usr/bin/env bash

: <<\#*************************************************************************

Utilized as part of wsl distro setups.
  - Returns nexus proxy url if active or canonical download url when not.

#*************************************************************************

asset=$1

if (echo "GET /service/rest/v1/status" >/dev/tcp/localhost/8081) &>/dev/null
then
  base_url="http://localhost:8081/repository"
fi

_gh_latest_release_tag() {
  path=$1
  url=https://api.github.com/repos${path}/latest
  [[ ${base_url:-} ]] && url=${url/"http"?":/"/"${base_url}"}
  tag=$(jq -r '.tag_name' <(curl -s ${url}))
  echo ${tag}
}

case "${asset,,}" in
  "cascadia-code")
    path=/microsoft/cascadia-code/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/download/${tag}/CascadiaCode-${tag:1}.zip
  ;;
  "darkstudio")
    : https://github.com/rileytwo/darkstudio/archive/master.tar.gz
  ;;
  "firacode")
    path=/tonsky/FiraCode/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/download/${tag}/Fira_Code_v${tag}.zip
  ;;
  "mathjax")
    path=/MathJax/MathJax/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/archive/${tag}.tar.gz
  ;;
  "mathjax-third-party-extensions")
    : https://github.com/mathjax/MathJax-third-party-extensions/archive/master.tar.gz
  ;;
  "pandoc")
    path=/jgm/pandoc/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/download/${tag}/pandoc-${tag}-1-amd64.deb
  ;;
  "powerline-go")
    path=/thell/powerline-go/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/download/${tag}/powerline-go.tar.gz
  ;;
  "pup")
    path=/EricChiang/pup/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/download/${tag}/pup_${tag}_linux_amd64.zip
  ;;
  "rscodeio")
    : https://github.com/anthonynorth/rscodeio/archive/master.tar.gz
  ;;
  "rstudio")
    path=".preview.desktop.bionic.rstudio"
    url=https://github.com/thell/rstudio-latest-urls/raw/master/latest.json
    [[ ${base_url:-} ]] && url=${url/"http:/"/"${base_url}"}
    : $(jq -r ${path} <(curl -s -L ${url}))
  ;;
  "tinytex")
    : https://yihui.org/tinytex/TinyTeX.tar.gz
  ;;
  "ubuntu-wsl2-systemd-script")
    : https://github.com/DamionGans/ubuntu-wsl2-systemd-script/master.tar.gz
  ;;
  "wsl-open")
    : https://github.com/4U6U57/wsl-open/raw/master/wsl-open.sh
  ;;
  *)
    exit 1
  ;;
esac
url="$_"

[[ ${base_url:-} ]] && url=${url/"http"?":/"/"${base_url}"}
echo ${url}

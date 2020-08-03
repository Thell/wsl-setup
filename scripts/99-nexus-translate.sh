#/bin/bash

: << '//NOTES//'

This script is meant to be sourced during WSL distro builds to provide
helper functions for acquiring URLs of installable packages.

Returns either the nexus translated or canonical download url.

//NOTES//

_nexus_status() {
  HTTP_STATUS=$(curl -s -w '%{http_code}\n' -X GET http://localhost:8081/service/rest/v1/status)
  [[ ${HTTP_STATUS} -eq 200 ]]
}

_url_effective() {
  curl -s -I -w '%{url_effective}\n' -L $1 -o /dev/null
}

_gh_latest_release_tag() {
  URL=$(_url_effective $1)
  echo ${URL##*/}
}

_nexus_github_archive_master_targz() {
  # Translate Github Repository Master tar bundle URL
  USER=$1
  REPO=$2
  URL=https://github.com/${USER}/${REPO}/archive/master.tar.gz
  if _nexus_status
  then
    URL=http://localhost:8081/repository/github/${USER}/${REPO}/archive/master.tar.gz
  fi
  echo ${URL}
}

nexus_mathjax_latest() {
  # Translate Latest Github Release Tag URL
  URL=https://github.com/MathJax/MathJax/releases/latest
  TAG=$(_gh_latest_release_tag ${URL})
  URL=https://github.com/mathjax/MathJax/archive/${TAG}.tar.gz
  if _nexus_status
  then
    URL=$(echo ${URL} | sed 's|s://github.com|://localhost:8081/repository/github|')
  fi
  echo ${URL}
}

nexus_mathjax_3rd_party_latest() {
  # Translate Github Master Tar URL
  # https://github.com/mathjax/MathJax-third-party-extensions/archive/master.tar.gz
  _nexus_github_archive_master_targz mathjax Mathjax-third-party-extensions
}

nexus_pandoc_latest_amd64() {
  # Translate Latest Github Release Tag URL
  URL=https://github.com/jgm/pandoc/releases/latest
  TAG=$(_gh_latest_release_tag ${URL})
  URL=https://github.com/jgm/pandoc/releases/download/${TAG}/pandoc-${TAG}-1-amd64.deb
  if _nexus_status
  then
    URL=$(echo ${URL} | sed 's|s://github.com|://localhost:8081/repository/github|')
  fi
  echo ${URL}
}

nexus_pup_latest_amd64() {
  # Translate Latest Github Release Tag URL
  URL=https://github.com/EricChiang/pup/releases/latest
  TAG=$(_gh_latest_release_tag ${URL})
  URL=https://github.com/ericchiang/pup/releases/download/${TAG}/pup_${TAG}_linux_amd64.zip
  if _nexus_status
  then
    URL=$(echo ${URL} | sed 's|s://github.com|://localhost:8081/repository/github|')
  fi
  echo ${URL}
}

nexus_darkstudio_latest() {
  # Translate Github Master Tar URL
  # https://github.com/rileytwo/darkstudio/archive/master.tar.gz
  _nexus_github_archive_master_targz rileytwo darkstudio
}

nexus_rscodeio_latest() {
  # Translate Github Master Tar URL
  # https://github.com/anthonynorth/rscodeio/archive/master.tar.gz
  _nexus_github_archive_master_targz anthonynorth rscodeio
}

nexus_rstudio_latest_amd64() {
  # Translate RStudio IDE OSS Preview Latest Release Tag URL
  URL=https://rstudio.org/download/latest/preview/desktop/bionic/rstudio-latest-amd64.deb
  URL=$(_url_effective ${URL})
  if _nexus_status
  then
    URL=$(echo ${URL} | sed 's|s://s3.amazonaws.com|://localhost:8081/repository|')
  fi
  echo ${URL}
}

nexus_wsl2_systemd_latest() {
  # Translate Github Master Tar URL
  _nexus_github_archive_master_targz DamionGans ubuntu-wsl2-systemd-script
}

nexus_tinytex_latest() {
  # Translate Latest Github Release Tag URL
  URL=https://github.com/yihui/tinytex/releases/latest
  TAG=$(_gh_latest_release_tag ${URL})
  URL=https://github.com/yihui/tinytex/archive/${TAG}.tar.gz
  if _nexus_status
  then
    URL=$(echo ${URL} | sed 's|s://github.com|://localhost:8081/repository/github|')
  fi
  echo ${URL}
}

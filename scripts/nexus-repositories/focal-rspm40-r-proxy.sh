#!/bin/bash

: << '//NOTES//'

Execute this script from Windows using:
wsl -d Ubuntu -u root -- ./scripts/nexus-repositories/focal-rspm40-r-proxy.sh

Assumes Nexus Admin password has not been changed yet and is available using
$(cat /opt/sonatype-work/nexus3/admin.password)

It will
- setup a RStudio Package Manager proxy repository on Nexus

Usage on client:
  options(repos = c(REPO_NAME = "http://localhost:8081/repository/focal-rspm-4.0-binary/"))

Nexus sends a fixed User Agent so we only need to set the repos option.

then test...
  sw.start <- Sys.time(); install.packages("usethis", quiet=TRUE); sw.end <- Sys.time(); sw.end - sw.start

//NOTES//

REPO_JSON_PATH="/tmp/repo.json"
cat > ${REPO_JSON_PATH} << \EOF
{
  "name": "focal-rspm-4.0-binary",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://packagemanager.rstudio.com/all/__linux__/focal/latest",
    "contentMaxAge": 1440,
    "metadataMaxAge": 1440
  },
  "negativeCache": {
    "enabled": true,
    "timeToLive": 1440
  },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "connection": {
      "retries": 0,
      "userAgentSuffix": "R/4.0.2 R (4.0.2 x86_64-pc-linux-gnu x86_64 linux-gnu)",
      "timeout": 20,
      "enableCircularRedirects": false,
      "enableCookies": true
    }
  },
  "routingRule": "string"
}

EOF

curl "http://localhost:8081/service/rest/beta/repositories/r/proxy" \
  -vvv --user admin:$(cat /opt/sonatype-work/nexus3/admin.password) \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d @${REPO_JSON_PATH}

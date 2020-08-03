#!/bin/bash

: << '//NOTES//'

Execute this script from Windows using:
wsl -d Ubuntu -u root -- ./scripts/nexus-repositories/focal-texlive-proxy.sh

Assumes Nexus Admin password has not been changed yet and is available using
$(cat /opt/sonatype-work/nexus3/admin.password)

It will
- setup a proxy repository on Nexus to https://mirror.las.iastate.edu/tex-archive/

Usage on client via environment variable (or set via tlmgr):
  export CTAN_REPO=http://localhost:8081/repository/texlive/tlnet

//NOTES//

REPO_JSON_PATH="/tmp/repo.json"
cat > ${REPO_JSON_PATH} << \EOF
{
  "name": "texlive",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": false
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://mirror.las.iastate.edu/tex-archive/systems/texlive/",
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
      "userAgentSuffix": "",
      "timeout": 20,
      "enableCircularRedirects": false,
      "enableCookies": true
    }
  },
  "routingRule": "string"
}

EOF

curl "http://localhost:8081/service/rest/beta/repositories/raw/proxy" \
  -vvv --user admin:$(cat /opt/sonatype-work/nexus3/admin.password) \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d @${REPO_JSON_PATH}

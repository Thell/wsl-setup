#!/usr/bin/env bash

: <<\#*************************************************************************

Execute this script from Windows using:
wsl -d Ubuntu -u root -- ./scripts/nexus-repositories/focal-cran40-apt-proxy.sh

Assumes Nexus Admin password has not been changed yet and is available using
$(cat /opt/sonatype-work/nexus3/admin.password)

It will
- setup a R focal-cran-4.0 proxy repository on Nexus.

Usage on client:
  sudo apt-add-repository "deb http://localhost:8081/repository/focal-cran-4.0-proxy focal-cran40/"

#*************************************************************************

REPO_JSON_PATH="/tmp/repo.json"
cat > ${REPO_JSON_PATH} << \EOF
{
  "name": "focal-cran-4.0-proxy",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://cloud.r-project.org/bin/linux/ubuntu",
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
      "userAgentSuffix": "string",
      "timeout": 60,
      "enableCircularRedirects": false,
      "enableCookies": false
    }
  },
  "routingRule": "string",
  "apt": {
    "distribution": "focal-cran40",
    "flat": false
  }
}
EOF

curl "http://localhost:8081/service/rest/beta/repositories/apt/proxy" \
  -vvv --user admin:$(cat /opt/sonatype-work/nexus3/admin.password) \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d @${REPO_JSON_PATH}

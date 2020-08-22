#!/usr/bin/env bash

: <<\#*************************************************************************

Execute this script from Windows using:
wsl -d Ubuntu -u root -- ./scripts/nexus-repositories/s3-amazonaws-proxy.sh

Assumes Nexus Admin password has not been changed yet and is available using
$(cat /opt/sonatype-work/nexus3/admin.password)

It will
- setup a proxy repository on Nexus to https://s3.amazonaws.com

Usage on client should be for package downloads:
  http://localhost:8081/repository/s3.amazonaws.com

#*************************************************************************


REPO_JSON_PATH="/tmp/repo.json"
cat > ${REPO_JSON_PATH} << \EOF
{
  "name": "s3.amazonaws.com",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": false
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://s3.amazonaws.com",
    "contentMaxAge": -1,
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

#!/bin/bash

: << '//NOTES//'
The idea here is to have apt-cacher-ng cache all of the regular sources.list
repos and use Nexus for those using https without double caching.

It will
- install openjdk-8-jre (from adoptopenjdk)
- setup systemd apt-cacher-ng with DontCache on localhost urls.
- setup systemd nexus repository
- add a log monitor.

Execute this script from Windows as user:
  wsl -d wsl-proxy -u root -- ./scripts/wsl-proxy-repositories.sh

The following will start both services and keep the terminal open for viewing.
wsl -d wsl-proxy -u thell -- wsl-tail-repo-logs

//NOTES//

cd ~
apt update
apt -y --no-install-recommends install curl gnupg software-properties-common

URL=https://github.com/DamionGans/ubuntu-wsl2-systemd-script/archive/master.tar.gz
curl -kL ${URL}  --output - | tar zxvf -
cd ./ubuntu-wsl2-systemd-script-master/
bash ./ubuntu-wsl2-systemd-script.sh
cd ~
rm -rf ./ubuntu-wsl2-systemd-script-master/

URL=https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public
curl -kL ${URL}  --output - | apt-key add -
add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
apt update
apt -y install apt-cacher-ng adoptopenjdk-8-hotspot-jre

cp /lib/systemd/system/apt-cacher-ng.service /etc/systemd/system/apt-cacher-ng.service
sed -i '/^ExecStart=/ s/$/ DontCache=".*localhost.*"/' /etc/systemd/system/apt-cacher-ng.service

cd /opt
URL=https://download.sonatype.com/nexus/3/latest-unix.tar.gz
curl -kL ${URL} --output - | tar zxf -
mv /opt/nexus-* /opt/nexus

NEXUS_DATA=/opt/sonatype-work/nexus3
useradd -r -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false nexus
chown -R nexus:nexus ${NEXUS_DATA}

cd ~
cat > ~/nexus.service << EOF
[Unit]
Description=nexus service
After=network.target
  
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600
  
[Install]
WantedBy=multi-user.target

EOF

mv ~/nexus.service /etc/systemd/system/
chmod 0644 /etc/systemd/system/nexus.service
systemctl enable nexus

cat > ~/nexus-start-monitor << EOF
sed "/^Started Sonatype Nexus.*$/ q" <(tail -f /opt/sonatype-work/nexus3/log/nexus.log)

EOF
mv ~/nexus-start-monitor /usr/local/bin/
chmod +x /usr/local/bin/nexus-start-monitor

cat > ~/wsl-tail-repo-logs << EOF
tail -f /var/log/apt-cacher-ng/apt-cacher.log \
  /var/log/apt-cacher-ng/apt-cacher.err \
  /opt/sonatype-work/nexus3/log/request.log

EOF
mv ~/wsl-tail-repo-logs /usr/local/bin/
chmod +x /usr/local/bin/wsl-tail-repo-logs

rm -f /etc/rs.d/NOPASSWD_ALL

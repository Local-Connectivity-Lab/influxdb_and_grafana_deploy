#!/bin/bash

set -e
set -u
set -o pipefail
set -x

if [ -z "${API_KEY:-}" ]; then
  echo "Error: API_KEY environment variable is not set."
  exit 1
fi


wget https://download.influxdata.com/influxdb/releases/influxdb2-2.7.11_linux_amd64.tar.gz
tar xvfz influxdb2-2.7.11_linux_amd64.tar.gz
rm influxdb2-2.7.11_linux_amd64.tar.gz


cat << EOF > /etc/systemd/system/influxdb.service
[Unit]
Description=influxdb
After=network.target

[Service]
Type=simple
ExecStart=/root/influxdb2-2.7.11/usr/bin/influxd --http-bind-address=0.0.0.0:8086
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl start influxdb
systemctl enable influxdb

apt install gpg
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh

cat << EOF > /etc/fluent-bit/fluent-bit.conf
[INPUT]
    Name cpu
    Tag cpu

[OUTPUT]
    Name influxdb
    Match cpu
    Host 127.0.0.1
    Port 8086
    Bucket metrics_proxmox_container
    Org scn
    HTTP_Token $API_KEY
EOF

systemctl restart fluent-bit

#!/bin/bash
set -e
set -u
set -o pipefail
set -x


wget https://dl.grafana.com/oss/release/grafana-11.5.2.linux-amd64.tar.gz
tar -zxvf grafana-11.5.2.linux-amd64.tar.gz
rm grafana-11.5.2.linux-amd64.tar.gz

cat << EOF > /etc/systemd/system/grafana.service
[Unit]
Description=grafana
After=network.target

[Service]
Type=simple
ExecStart=/root/grafana-v11.5.2/bin/grafana server --homepath /root/grafana-v11.5.2
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable grafana
systemctl start grafana

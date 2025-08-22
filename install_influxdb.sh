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

cat << EOF > /etc/fluent-bit/parsers2.conf
[PARSER]
    Name   meminfo
    Format regex
    Regex  mem_total=(?<mem_total>\d+) mem_available=(?<mem_available>\d+)
EOF

cat << EOF > /etc/fluent-bit/convert_to_int.lua
function convert_mem_values(tag, timestamp, record)
    record["mem_total"] = tonumber(record["mem_total"])
    record["mem_available"] = tonumber(record["mem_available"])
    return 1, timestamp, record
end
EOF

cat << EOF > /etc/fluent-bit/fluent-bit.conf
[SERVICE]
    parsers_file parsers2.conf

[INPUT]
    Name cpu
    Tag cpu
    interval_sec 5
    

[INPUT]
    name        exec
    command     free | awk 'NR==2 { printf "mem_total=%d mem_available=%d\n", $2, $7 }'
    interval_sec 5
    tag         mfm
    parser      meminfo

[FILTER]
    Name    lua
    Match   mfm
    script  /etc/fluent-bit/convert_to_int.lua
    call    convert_mem_values
    

[INPUT]
    Name netif
    Tag network
    Interface eth0
    interval_sec 5

[INPUT]
    Name disk
    Tag disk
    interval_sec 5

[OUTPUT]
    name stdout
    match *
    format json_lines

[OUTPUT]
    Name influxdb
    Match *
    Host 127.0.0.1
    Port 8086
    Bucket metrics_proxmox_container
    Org scn
    HTTP_Token $API_KEY
EOF

systemctl restart fluent-bit

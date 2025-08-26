# Instalation
installs influxdb (v2) and grafana on debian/ubuntu

run the install_grafana script to install grafana, run the install_influxdb script to install influxdb

When you start influxdb, go to the webpage `:8086` and create an admin user, save the token it gives you. Then install grafana using the script, go to `:3000` and create an admin user. Connect the two by going to the conntections tab in grafana and adding a flux query without basic auth. It will ask you in a field for the api key. You need to go back to influxdb and create a api key that allows reading all buckets. Then paste the key back in grafana. The connection should succeed.

I used fluentbit to push metrics to influxdb in the influxdb instalation script

# Onboarding a server
Generate an api key that has write access to the bucket you want the metric to go into.
1. Create a bucket with a useful name https://influxdb.infra.seattlecommunitynetwork.org/orgs/6453e782da8301c7/load-data/buckets
2. Generate a custom API token with write access to your desired bucket https://influxdb.infra.seattlecommunitynetwork.org/orgs/6453e782da8301c7/load-data/tokens
3. Use this token to send requests to influxdb

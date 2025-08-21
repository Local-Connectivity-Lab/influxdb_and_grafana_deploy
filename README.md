installs influxdb and grafana on debian/ubuntu

run the install_grafana script to install grafana, rin the install_influxdb script to install influxdb

When you start influxdb, go to the webpage `:8086` and create an admin user, save the token it gives you. Then install grafana using the script, go to `:3000` and create an admin user. Connect the two by going to the conntections tab in grafana and adding a flux query without basic auth. It will ask you in a field for the api key. You need to go back to influxdb and create a api key that allows reading all buckets. Then paste the key back in grafana. The connection should succeed. When you want to onboard a server, you need to generate an api key that has write access to the bucket you want.

I used fluentbit to push metrics to influxdb in the influxdb instalation script

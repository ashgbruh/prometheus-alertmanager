#!/bin/bash 

#Create a system user for Prometheus:
sudo useradd --no-create-home --shell /bin/false prometheus

#Create the directories in which we'll be storing our configuration files and libraries:
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

#Set the ownership of the /var/lib/prometheus directory:
sudo chown prometheus:prometheus /var/lib/prometheus

#Pull down the tar.gz file from the Prometheus downloads page:
cd /tmp/
wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz

#Extract the files:
tar -xvf prometheus-2.7.1.linux-amd64.tar.gz

#Move the configuration file and set the owner to the prometheus user:
cd prometheus-2.7.1.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

#Move the binaries and set the owner:
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

#Create the service file:
echo "

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

" >> /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

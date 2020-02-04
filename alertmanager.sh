#!/bin/bash 

#Create the alertmanager system user:
sudo useradd --no-create-home --shell /bin/false alertmanager

#Create the /etc/alertmanager directory:
sudo mkdir /etc/alertmanager

#Download Alertmanager from the Prometheus downloads page:
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.16.1/alertmanager-0.16.1.linux-amd64.tar.gz

#Extract the files:
tar -xvf alertmanager-0.16.1.linux-amd64.tar.gz

#Move the binaries:
cd alertmanager-0.16.1.linux-amd64
sudo mv alertmanager /usr/local/bin/
sudo mv amtool /usr/local/bin/

#Set the ownership of the binaries:
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

#Move the configuration file into the /etc/alertmanager directory:
sudo mv alertmanager.yml /etc/alertmanager/

#Set the ownership of the /etc/alertmanager directory:
sudo chown -R alertmanager:alertmanager /etc/alertmanager/

#Create the alertmanager.service file for systemd:
sudo $EDITOR /etc/systemd/system/alertmanager.service

[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml
[Install]
WantedBy=multi-user.target

#Stop Prometheus, and then update the Prometheus configuration file to use Alertmanager:
sudo systemctl stop prometheus
sudo $EDITOR /etc/prometheus/prometheus.yml

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
      
#Reload systemd, and then start the prometheus and alertmanager services:
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl start alertmanager

#Make sure alertmanager starts on boot:
sudo systemctl enable alertmanager

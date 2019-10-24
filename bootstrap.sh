#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive 


/usr/bin/cloud-init -d init
/usr/bin/cloud-init -d modules
apt-get update 
apt-get -y upgrade
apt-get -y install \
    git curl wget \
    apt-transport-https \
    ca-certificates \
    curl \
    sudo \
    vim \
    nano \
    python3 \
    python3-pip \
    software-properties-common \
    jq

# Install Docker
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install cloud libraries
pip3 install awscli google-cloud boto3 'docker[tls]'

# install k3s
curl -sfL https://get.k3s.io | sh -

# install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /usr/local/bin

# Improve the startup sequence
echo "INFO: copying ./resources to /"
(cd /tmp/resources ; cp -r ./ /)
for cloud in aws gcloud; do
	systemctl enable instruqt-configure-$cloud.path
	systemctl start  instruqt-configure-$cloud.path
done
systemctl daemon-reload

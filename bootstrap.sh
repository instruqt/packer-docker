#!/bin/bash

set -eux
echo "Installing Docker ${DOCKER_VERSION} and Compose ${DOCKER_COMPOSE_VERSION}"

export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get -y upgrade
apt-get -y install \
    curl \
    wget \
    git \
    apt-transport-https \
    ca-certificates \
    curl \
    sudo \
    gnupg-agent \
    software-properties-common

curl -fsSL https://get.docker.com -o get-docker.sh && chmod +x get-docker.sh
sudo sh get-docker.sh --version "${DOCKER_VERSION}"
rm get-docker.sh

mkdir -p /etc/docker/

sudo usermod -aG docker root
sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

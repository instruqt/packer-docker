#!/bin/bash

export DEBIAN_FRONTEND=noninteractive 

apt-get update && apt-get -y upgrade
apt-get -y install \
    git curl wget \
    apt-transport-https \
    ca-certificates \
    curl \
    sudo \
    unzip \
    vim \
    nano \
    joe \
    emacs \
    gnupg2 \
    software-properties-common

curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce

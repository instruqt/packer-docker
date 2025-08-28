variable "docker_version" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

source "googlecompute" "docker" {
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  image_family = "docker-${regex_replace(var.docker_version, "[^0-9]", "-")}"
  image_name   = "docker-${regex_replace(var.docker_version, "[^0-9]", "-")}-${uuidv4()}"

  source_image_family             = "ubuntu-minimal-2404-lts-amd64"
  machine_type                    = "n1-standard-4"
  disk_size                       = 20
  disable_default_service_account = true

  ssh_username = "root"

  image_labels = {
    track   = "docker"
    created = "{{ timestamp }}"
  }
}

build {
  sources = ["source.googlecompute.docker"]

  provisioner "file" {
    source = "daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /etc/docker",
      "mv /tmp/daemon.json /etc/docker/daemon.json",
    ]
  }

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update && apt-get -y upgrade",
      "apt-get -y install curl wget git apt-transport-https ca-certificates curl sudo gnupg-agent software-properties-common",
      "curl -fsSL https://get.docker.com | sudo sh",
      "sudo usermod -aG docker root",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
    ]
  }
}

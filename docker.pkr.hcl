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

  image_family = "docker"
  image_name   = "docker-2010-v2"

  source_image_family             = "ubuntu-2204-lts"
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
    sources = ["resources/google-startup-scripts.service"]
    destination = "/tmp/resources"
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

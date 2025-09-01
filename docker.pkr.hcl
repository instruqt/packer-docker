variable "docker_version" {
  type = string
}

variable "docker_compose_version" {
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

  provisioner "shell" {
    script = "bootstrap.sh"
    env = {
      DOCKER_VERSION         = var.docker_version
      DOCKER_COMPOSE_VERSION = var.docker_compose_version
    }
  }

  provisioner "file" {
    source      = "resources/daemon.json"
    destination = "/etc/docker/daemon.json"
  }
}

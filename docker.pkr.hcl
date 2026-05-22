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
    qemu = {
      source  = "github.com/hashicorp/qemu"
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

source "qemu" "docker" {
  iso_url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  iso_checksum     = "file:https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
  disk_image       = true
  output_directory = "output-docker"
  vm_name          = "docker-vm.qcow2"
  format           = "qcow2"
  disk_size        = "20G"

  accelerator  = "kvm"
  machine_type = "q35"
  cpus         = 4
  memory       = 4096

  headless         = true
  ssh_username     = "root"
  ssh_password     = "packer"
  ssh_timeout      = "5m"
  shutdown_command = "shutdown -P now"

  cd_files = ["cloud-init/meta-data", "cloud-init/user-data"]
  cd_label = "cidata"
}

build {
  sources = [
    "source.googlecompute.docker",
    "source.qemu.docker",
  ]

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

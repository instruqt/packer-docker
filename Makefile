PROJECT_ID ?= $(shell gcloud config get project)
VERSION ?= 28.3

build:
	packer build -var 'project_id=${PROJECT_ID}' -var 'docker_version=${VERSION}' docker.pkr.hcl

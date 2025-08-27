PROJECT_ID ?= $(shell gcloud config get project)

build:
	packer build -var 'project_id=${PROJECT_ID}' docker.pkr.hcl

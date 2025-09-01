PROJECT_ID ?= instruqt
DOCKER_VERSION ?= 28.3
DOCKER_COMPOSE_VERSION ?= 2.39.2

build:
	packer build -var 'project_id=${PROJECT_ID}' -var 'docker_version=${DOCKER_VERSION}' -var 'docker_compose_version=${DOCKER_COMPOSE_VERSION}' docker.pkr.hcl

ts := $(shell /bin/date "+%s")

check-variables:
ifndef PROJECT
  $(error PROJECT is undefined)
endif

build: check-variables
	packer build -var 'project_id=${PROJECT}' packer.json
	gcloud compute images add-iam-policy-binding ubuntu-1804-lts-docker \
		--role  roles/compute.imageUser \
		--member serviceAccount:instruqt-track@instruqt-prod.iam.gserviceaccount.com

force-build: check-variables
	packer build -force -var 'project_id=${PROJECT}' packer.json
	gcloud compute images add-iam-policy-binding ubuntu-1804-lts-docker \
		--role  roles/compute.imageUser \
		--member serviceAccount:instruqt-track@instruqt-prod.iam.gserviceaccount.com


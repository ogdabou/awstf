# Created when investigating Packer

SHELL := /bin/bash
.ONESHELL:

build-images:
	@cd src/modules/nomad
	@/usr/bin/packer build -var-file=variables.hcl image.pkr.hcl

build: build-images

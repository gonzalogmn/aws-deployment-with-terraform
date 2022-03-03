current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL = /bin/sh

AWS_PROFILE=admin-ec2-deployment-demo
AWS_REGION=$(shell grep aws_default_region terraform/terraform.tfvars | cut -d'"' -f 2)
APP_VERSION=$(shell cd demo-api && mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version  | grep -v '\[')

start:
	@if [ -z $(shell which mvn) ]; then echo "ERROR: missing software required: maven" > /dev/stderr && exit 1; fi
	@if [ -z $(shell which packer) ]; then echo "ERROR: missing software required: packer" > /dev/stderr && exit 1; fi
	@if [ -z $(shell which ansible) ]; then echo "ERROR: missing software required: ansible" > /dev/stderr && exit 1; fi
	@if [ -z $(shell which terraform) ]; then echo "ERROR: missing software required: terraform" > /dev/stderr && exit 1; fi
	@cd terraform && tfenv install
	@cd terraform && terraform init
	@echo "Everything's fine :) Have fun!"

build:
	@if [ -z $(shell which mvn) ]; then echo "ERROR: missing software required: maven" > /dev/stderr && exit 1; fi
	@echo "Building demo-api artifact with version ${APP_VERSION}"
	@cd demo-api && mvn clean package

upload-ami: build
	@if [ -z $(shell which packer) ]; then echo "ERROR: missing software required: packer" > /dev/stderr && exit 1; fi
	@if [ -z $(shell which ansible) ]; then echo "ERROR: missing software required: ansible" > /dev/stderr && exit 1; fi
	@packer validate .
	@packer build .

deploy:
	@echo "Applying Terraform changes to update project to version ${APP_VERSION}"
	@cd terraform && terraform init && terraform apply -var="app_version=${APP_VERSION}"

PHONY: start build upload-ami deploy
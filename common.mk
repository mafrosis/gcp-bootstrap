.PHONY: all clean test

BOOTSTRAP_PROJECT_ID?=bootstrap-$(ORG_ID)

.PHONY: help
help:
	@echo 'make init        Setup Terraform for first run'

.PHONY: init
init: _remove-dot-terraform .terraform
	@true

.PHONY: _remove-dot-terraform
_remove-dot-terraform:
	@rm -rf .terraform

.terraform:
	terraform init -backend-config=bucket=$(BOOTSTRAP_PROJECT_ID) -reconfigure

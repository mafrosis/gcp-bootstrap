.PHONY: all clean test

ORG_ID?=412577173587
ORG?=gcp.mafro.dev
BOOTSTRAP_PROJECT_ID?=bootstrap-$(ORG_ID)

.PHONY: help
help:
	@echo 'make init					Setup Terraform for first run'
	@echo 'make bootstrap-resources		Import into Terraform bootstrap resources created by bin/boostrap.sh'

.PHONY: init
init: _remove-dot-terraform .terraform
	@true

.PHONY: _remove-dot-terraform
_remove-dot-terraform:
	@rm -rf .terraform

.terraform:
	terraform init -backend-config=bucket=$(BOOTSTRAP_PROJECT_ID)

.PHONY: bootstrap-resources
bootstrap-resources: .terraform
	@if ! terraform state list | grep google_storage_bucket.terraform_state; then \
		terraform import google_storage_bucket.terraform_state $(BOOTSTRAP_PROJECT_ID)/$(BOOTSTRAP_PROJECT_ID); \
	fi
	@if ! terraform state list | grep google_project.bootstrap; then \
		terraform import google_project.bootstrap $(BOOTSTRAP_PROJECT_ID); \
	fi
	@if ! terraform state list | grep google_service_account.terraform; then \
		terraform import google_service_account.terraform projects/$(BOOTSTRAP_PROJECT_ID)/serviceAccounts/terraform-root@$(BOOTSTRAP_PROJECT_ID).iam.gserviceaccount.com; \
	fi

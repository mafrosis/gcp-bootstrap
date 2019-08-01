include ../common.mk

.PHONY: help
help:
	@echo 'make init                   Setup Terraform for first run'
	@echo 'make bootstrap-resources    Import into Terraform bootstrap resources created by bin/boostrap.sh'

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

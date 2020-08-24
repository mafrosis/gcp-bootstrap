include ../common.mk

.PHONY: help
help:
	@echo 'make init         Setup Terraform for first run'
	@echo 'make bootstrap    Finish the bootstrap process with Terraform'


.terraform:
	terraform init -backend-config=bucket=$(BOOTSTRAP_PROJECT_ID) -backend-config=prefix=$(BOOTSTRAP_PROJECT_ID) -reconfigure


.PHONY: bootstrap
bootstrap: init import-resources
	terraform apply


.PHONY: import-resources
import-resources: .terraform
	@if ! terraform state list | grep "^google_storage_bucket.terraform_state$$"; then \
		terraform import google_storage_bucket.terraform_state $(BOOTSTRAP_PROJECT_ID)/$(BOOTSTRAP_PROJECT_ID); \
	fi
	@if ! terraform state list | grep "^google_project.bootstrap$$"; then \
		terraform import google_project.bootstrap $(BOOTSTRAP_PROJECT_ID); \
	fi
	@if ! terraform state list | grep "^google_service_account.terraform$$"; then \
		terraform import google_service_account.terraform projects/$(BOOTSTRAP_PROJECT_ID)/serviceAccounts/terraform-root@$(BOOTSTRAP_PROJECT_ID).iam.gserviceaccount.com; \
	fi


.PHONY: get-service-account-key
get-service-account-key:
	@echo "$$(terraform output tf_project_creator_key)" | base64 --decode

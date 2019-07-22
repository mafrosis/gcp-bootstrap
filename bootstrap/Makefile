.PHONY: all clean test

ORG_ID?=412577173587
ORG?=gcp.mafro.dev
BOOTSTRAP_BUCKET_PREFIX?=bootstrap

.PHONY: help
help:
	@echo 'make init             Setup Terraform for first run'
	@echo 'make bucket-import    Import bootstrapped state bucket under terraform control'

.PHONY: init
init:
	terraform init -backend-config=bucket=$(BOOTSTRAP_BUCKET_PREFIX)-$(ORG_ID)

.PHONY: bucket-import
bucket-import: init
	@if ! terraform state list | grep google_storage_bucket.terraform_state; then \
		terraform import google_storage_bucket.terraform_state $(BOOTSTRAP_PROJECT_ID)/$(BOOTSTRAP_PROJECT_ID); \
	fi

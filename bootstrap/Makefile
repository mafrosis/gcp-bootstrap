.PHONY: all clean test

ORG_ID?=412577173587
ORG?=gcp.mafro.dev
BOOTSTRAP_BUCKET_PREFIX?=bootstrap

.PHONY: init
init:
	terraform init -backend-config=bucket=$(BOOTSTRAP_BUCKET_PREFIX)-$(ORG_ID)

# GCP Bootstrap

This repo sets out to bootstrap a GCP account (aka organisation) for management with Terraform.


## Requirements

- `bash`
- `terraform`


## Boostrapping a new GCP Organisation

### 0. Prerequisites

You first need a billing account setup (and Billing Account Creator role is required to do this).

The user used to bootstrap GCP will need only a single role:

- Project Creator

### 1. Bootstrap with the script

First login to your GCP account with `gcloud`:

    gcloud auth login

And now `cd` into the `bootstrap` directory:

    cd bootstrap

Run the bootstrap script, replacing `ORG_ID` with your organisation's ID, and `BILLING_ACCOUNT_ID`
with your billing account ID:

    ./bin/bootstrap-org.sh ORG_ID BILLING_ACCOUNT_ID

You can optionally configure the name of the project which hosts terraform state, and name of the file
into which your root terraform service account key is written.

This script is safe to re-run in the event of failures, so keep trying until get a success.. which
looks like this:

```
******* Bootstrap Complete *******
* Terraform project bootstrap-999999999999 and root service account is setup
* Billing account is ABCDEF-123456-ABCDEF
*
* These variables have been written to terraform.auto.tfvars and credentials have been written to
* terraform-root.json
*
* Now, run the following to complete the bootstrap:
*
* > export GOOGLE_APPLICATION_CREDENTIALS=terraform-root.json
* > BOOTSTRAP_PROJECT_ID=bootstrap-999999999999 make bootstrap
**********************************
```

### 2. Bootstrap with terraform

Now use terraform complete the bootstrap process. Use the instructions printed by the bash script in
step 1:

    export GOOGLE_APPLICATION_CREDENTIALS=terraform-root.json
    make init
    terraform apply -var billing_account=ABCDEF-123456-ABCDEF -var bootstrap_project_id=bootstrap-999999999999


## What is this magika?

### foundation Project with Bash

Use bash to create a "foundation project" with a "Terraform superuser" service account; which has the
following roles:

- Organisation Admin
- Service Account Admin

The foundation project is called `foundation-${ORG_ID}`. It has the following:
- A bucket for terraform state storage
- State bucket object admin access for terraform-superuser


### Manage the Organisation assets with Terraform

This "Terraform superuser" service account then runs the Organisation management terraform config.
This creates:

- Users
- "Terraform general purpose" service account
- State bucket object admin access for terraform-general
- Folder hierarchy
- Org policies
- Forseti project (special case!)

The "Terraform general purpose" service account can create VPCs and projects; which has the following roles:
- Organisation Viewer
- Project Creator
- ...

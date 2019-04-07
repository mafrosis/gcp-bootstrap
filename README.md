# GCP Bootstrap

This repo sets out to bootstrap a GCP account (aka organisation) for management with Terraform.


## Requirements

- `bash`
- `terraform`


## foundation Project with Bash

Use bash to create a "foundation project" with a "Terraform superuser" service account; which has the following roles:
- Organisation Admin
- Service Account Admin
And the following APIs:
- 
The foundation project is called `foundation-${ORG_ID}`. It has the following:
- A bucket for terraform state storage
- State bucket object admin access for terraform-superuser


## Manage the Organisation assets with Terraform

This "Terraform superuser" service account then runs the Organisation management terraform config. This creates:
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

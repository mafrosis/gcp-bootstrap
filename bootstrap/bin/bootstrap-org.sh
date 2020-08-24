#! /bin/bash -e

USAGE='bootstrap-org.sh ORG_ID BILLING_ACCOUNT_ID [BOOTSTRAP_PROJECT] [KEY_FILEPATH]

  ORG_ID               GCP organisation id
  BILLING_ACCOUNT_ID   Optionally link a billing account to the Terraform state project
  BOOTSTRAP_PROJECT    Name of the bootstrap project, which hosts terraform state in Cloud Storage
                         default: bootstrap-{ORG_ID}
  KEY_FILEPATH         Local filepath in which to store service account key
                         default: terraform-root.json'

if [[ $# -gt 4 || $# -lt 1 ]]; then
	echo "$USAGE"
	exit 1
fi


ORG_ID=$1
BILLING_ACCOUNT_ID=$2
BOOTSTRAP_PROJECT=${3:-bootstrap-$ORG_ID}
KEY_FILEPATH="${4:-terraform-root.json}"

# Display current gcloud user
CURRENT_SA="$(gcloud config list account --format "value(core.account)")"
printf "\\nYou are currently logged in as %s\\n\\n" "${CURRENT_SA}"

if ! gcloud projects list | grep "${BOOTSTRAP_PROJECT}" &>/dev/null; then
	printf "The foundation project (%s) does not current exist. Creating..\\n\\n" "${BOOTSTRAP_PROJECT}"

	# Create FOUNDATION project
	gcloud projects create "${BOOTSTRAP_PROJECT}" \
		--organization "${ORG_ID}"

	echo "Created project ${BOOTSTRAP_PROJECT}"
else
	echo "Project exists ${BOOTSTRAP_PROJECT}"
fi

if [[ -n $BILLING_ACCOUNT_ID ]]; then
	# link billing to FOUNDATION state project
	gcloud beta billing projects link "${BOOTSTRAP_PROJECT}" \
		--billing-account "${BILLING_ACCOUNT_ID}"
else
	echo "Skipping billing link (not set)"
fi

for API in cloudbilling.googleapis.com \
	cloudkms.googleapis.com \
	cloudresourcemanager.googleapis.com \
	compute.googleapis.com \
	dns.googleapis.com \
	iam.googleapis.com; do

	echo "Enabling ${API}"
	gcloud services enable --project="${BOOTSTRAP_PROJECT}" ${API}
done

if ! gcloud iam service-accounts list --project="${BOOTSTRAP_PROJECT}" | grep terraform &>/dev/null; then

	echo "Creating terraform service account"

	# Create the account terraform will use
	gcloud iam service-accounts create terraform-root \
		--project="${BOOTSTRAP_PROJECT}" \
		--display-name "Terraform"

	# Create the service key for the above account
	gcloud iam service-accounts keys create "${KEY_FILEPATH}" \
		--project="${BOOTSTRAP_PROJECT}" \
		--iam-account "terraform-root@${BOOTSTRAP_PROJECT}.iam.gserviceaccount.com"
else
	echo "Terraform service account already exists"
fi

if ! gsutil list -p "${BOOTSTRAP_PROJECT}" "gs://${BOOTSTRAP_PROJECT}"; then

	echo "Creating terraform cloud storage bucket"

	# Create a Cloud Storage bucket for Terraform remote state
	gsutil mb -b on \
		-l australia-southeast1 \
		-p "${BOOTSTRAP_PROJECT}" \
		"gs://${BOOTSTRAP_PROJECT}"
else
	echo "Terraform cloud storage bucket already exists"
fi

# Grant the following permissions at organization level for the ROOT service account:
# - Billing Account User
# - Editor
# - Service Account Admin
# - Service Account Key Admin
# - Folder Admin
# - Organization Admin

CURRENT_ROLES="$(gcloud organizations get-iam-policy "${ORG_ID}" --format json | jq --raw-output ".bindings[] | select( .members[] | contains(\"terraform-root@${BOOTSTRAP_PROJECT}.iam.gserviceaccount.com\") ) | .role")"

for ROLE in billing.user \
	editor \
	iam.serviceAccountAdmin \
	iam.serviceAccountKeyAdmin \
	resourcemanager.folderAdmin \
	resourcemanager.organizationAdmin; do

	if [[ $CURRENT_ROLES != *"$ROLE"* ]]; then
		gcloud organizations add-iam-policy-binding "${ORG_ID}" \
			--member "serviceAccount:terraform-root@${BOOTSTRAP_PROJECT}.iam.gserviceaccount.com" \
			--role "roles/${ROLE}" \
			&>/dev/null

		echo "$ROLE applied to terraform service account"
	else
		echo "$ROLE already set"
	fi
done

# Grant the following permissions at bootstrap project level for the ROOT service account:
# - Storage Admin
gcloud projects add-iam-policy-binding "${BOOTSTRAP_PROJECT}" \
	--member "serviceAccount:terraform-root@${BOOTSTRAP_PROJECT}.iam.gserviceaccount.com" \
	--role roles/storage.admin \
	&>/dev/null


# delete the default VPC created in the bootstrap project
if gcloud --project "${BOOTSTRAP_PROJECT}" compute networks list | grep -v default; then
	gcloud --project "${BOOTSTRAP_PROJECT}" compute firewall-rules delete -q default-allow-icmp
	gcloud --project "${BOOTSTRAP_PROJECT}" compute firewall-rules delete -q default-allow-internal
	gcloud --project "${BOOTSTRAP_PROJECT}" compute firewall-rules delete -q default-allow-rdp
	gcloud --project "${BOOTSTRAP_PROJECT}" compute firewall-rules delete -q default-allow-ssh

	gcloud --project "${BOOTSTRAP_PROJECT}" compute networks delete -q default
fi

tee terraform.auto.tfvars > /dev/null <<EOF
billing_account = "${BILLING_ACCOUNT_ID}"
bootstrap_project_id = "${BOOTSTRAP_PROJECT}"
EOF

cat << EOF

******* Bootstrap Complete *******
* Terraform project ${BOOTSTRAP_PROJECT} and root service account is setup
* Billing account is ${BILLING_ACCOUNT_ID}
*
* These variables have been written to terraform.auto.tfvars and credentials have been written to
* ${KEY_FILEPATH}
*
* Now, run the following to complete the bootstrap:
*
* > export GOOGLE_APPLICATION_CREDENTIALS=${KEY_FILEPATH}
* > BOOTSTRAP_PROJECT_ID=${BOOTSTRAP_PROJECT} make bootstrap
**********************************
EOF

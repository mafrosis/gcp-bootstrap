#! /bin/bash -e

USAGE='bootstrap-org.sh ORG_ID BOOTSTRAP_PROJECT [KEY_FILEPATH] [BILLING_ACCOUNT_ID]

  ORG_ID               GCP organisation id
  BOOTSTRAP_PROJECT   Terraform state project
  KEY_FILEPATH         Local filepath in which to store service account key (default: terraform-root.json)
  BILLING_ACCOUNT_ID   Optionally link a billing account to the Terraform state project'

if [[ $# -ne 3 && $# -ne 4 ]]; then
	echo "$USAGE"
	exit 1
fi


ORG_ID=$1
BOOTSTRAP_PROJECT=$2
KEY_FILEPATH="${3:-terraform-root.json}"
BILLING_ACCOUNT_ID=$4

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
	cloudresourcemanager.googleapis.com \
	compute.googleapis.com \
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

	for BUCKET in ${BOOTSTRAP_PROJECT} ${BOOTSTRAP_PROJECT}-logs; do
		# Create a Cloud Storage bucket for Terraform remote state & logs
		gsutil mb -b on \
			-l australia-southeast1 \
			-p "${BOOTSTRAP_PROJECT}" \
			"gs://${BUCKET}"
	done
else
	echo "Terraform cloud storage bucket already exists"
fi

# Grant the following permissions at organization level for the ROOT service account:
# - Billing Account User
# - Editor
# - Service Account Admin
# - Service Account Key Admin
# - Organization Admin
# - Storage Admin

CURRENT_ROLES="$(gcloud organizations get-iam-policy "${ORG_ID}" --format json | jq --raw-output ".bindings[] | select( .members[] | contains(\"terraform-root@${BOOTSTRAP_PROJECT}.iam.gserviceaccount.com\") ) | .role")"

for ROLE in billing.user \
	editor \
	iam.serviceAccountAdmin \
	iam.serviceAccountKeyAdmin \
	resourcemanager.folderAdmin \
	resourcemanager.organizationAdmin \
	storage.admin; do

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

# delete the default VPC created in our Foundations project
if gcloud --project "${BOOTSTRAP_PROJECT}" compute networks list | grep -v default; then
	gcloud --project "${BOOTSTRAP_PROJECT}" compute networks delete default
fi

cat << EOF

******* Bootstrap Complete *******
* Terraform project ${BOOTSTRAP_PROJECT} and root service account is setup.
* Credentials have been written to ${KEY_FILEPATH}.
**********************************
EOF

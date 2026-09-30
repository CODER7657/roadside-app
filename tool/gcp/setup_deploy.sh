#!/usr/bin/env bash
# Keyless GitHub → Firebase deploys for one project (PLAN.md §12.8, issue #41). Safe to re-run.
#
#   bash tool/gcp/setup_deploy.sh roadside-33282 development          # dev (Spark: rules, indexes, hosting)
#   bash tool/gcp/setup_deploy.sh roadside-prod  production --blaze   # prod, once on Blaze
#
# Creates:
#   - service account github-deploy@<project>, no keys
#   - Workload Identity pool "github" + OIDC provider "github-actions", accepting only tokens from
#     this repo (matched by numeric id, so a renamed or re-created repo can't use it), from jobs
#     running in the given GitHub environment, and from the right ref: `production` only from a
#     v* tag (admins-only tag ruleset), anything else only from main. Without the ref check, anyone
#     with write access could dispatch deploy-firebase.yml from their own branch with target=prod.
#   - roles for the service account: Firebase Rules Admin, Cloud Datastore Index Admin, Firebase
#     Hosting Admin and Service Usage Consumer (no access to data); --blaze adds what Functions and
#     Storage deploys need. Firebase Admin, granted by earlier versions, is removed.
# Prints the repo variables to set (needs repo admin: Settings → Secrets and variables → Actions).
#
# Needs: gcloud signed in (`gcloud auth login`) as a project Owner, and gh signed in.
# Windows (Git Bash):
#   nothing to set: in Git Bash the script uses tool/gcp/gcloud-win.sh, which runs gcloud through its
#   bundled Python (gcloud.cmd breaks on arguments with spaces when the SDK is under "Cloud SDK").
set -euo pipefail

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) GCLOUD=${GCLOUD:-"$(dirname "$0")/gcloud-win.sh"} ;;
  *) GCLOUD=${GCLOUD:-gcloud} ;;
esac
REPO=${REPO:-CODER7657/roadside-app}
project=${1:?usage: setup_deploy.sh <project-id> <github-environment> [--blaze]}
environment=${2:?usage: setup_deploy.sh <project-id> <github-environment> [--blaze]}
blaze=${3:-}

pool=github
provider=github-actions
sa_name=github-deploy
sa="$sa_name@$project.iam.gserviceaccount.com"

number=$("$GCLOUD" projects describe "$project" --format='value(projectNumber)')
repo_id=$(gh api "repos/$REPO" --jq .id)
owner_id=$(gh api "repos/$REPO" --jq .owner.id)
echo "Project $project ($number), repo $REPO ($repo_id), environment $environment"

echo "Enabling APIs…"
"$GCLOUD" services enable --project "$project" \
  iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com \
  cloudresourcemanager.googleapis.com serviceusage.googleapis.com \
  firebase.googleapis.com firebaserules.googleapis.com firebasehosting.googleapis.com \
  firestore.googleapis.com

if ! "$GCLOUD" iam service-accounts describe "$sa" --project "$project" >/dev/null 2>&1; then
  "$GCLOUD" iam service-accounts create "$sa_name" --project "$project" \
    --display-name "GitHub Actions deploy" \
    --description "deploy-firebase.yml via Workload Identity, no keys"
fi

# Least privilege: only what `firebase deploy` needs for rules, indexes (and TTL) and hosting. None of
# these can read customer data, unlike Firebase Admin, which a leaked workflow token would expose.
roles=(roles/firebaserules.admin roles/datastore.indexAdmin roles/firebasehosting.admin
       roles/serviceusage.serviceUsageConsumer)
if [ "$blaze" = "--blaze" ]; then
  roles+=(roles/cloudfunctions.admin roles/run.admin roles/iam.serviceAccountUser
          roles/artifactregistry.admin roles/cloudscheduler.admin roles/secretmanager.viewer
          roles/firebasestorage.viewer)
fi
for role in "${roles[@]}"; do
  "$GCLOUD" projects add-iam-policy-binding "$project" --member "serviceAccount:$sa" --role "$role" \
    --condition=None --quiet >/dev/null
  echo "  $role"
done

# Roles earlier versions of this script granted: removed on re-run.
for role in roles/firebase.admin; do
  if "$GCLOUD" projects remove-iam-policy-binding "$project" --member "serviceAccount:$sa" --role "$role" \
       --condition=None --quiet >/dev/null 2>&1; then
    echo "  removed $role"
  fi
done

if ! "$GCLOUD" iam workload-identity-pools describe "$pool" --project "$project" --location global >/dev/null 2>&1; then
  "$GCLOUD" iam workload-identity-pools create "$pool" --project "$project" --location global \
    --display-name "GitHub Actions"
fi

# Which refs may deploy: prod only from a release tag, dev only from main (unreviewed branches never).
case "$environment" in
  production) ref_rule="assertion.ref.startsWith('refs/tags/v')" ;;
  *) ref_rule="assertion.ref == 'refs/heads/main'" ;;
esac
condition="assertion.repository_id == '$repo_id' && assertion.repository_owner_id == '$owner_id' && assertion.environment == '$environment' && $ref_rule"
mapping="google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.environment=assertion.environment"
if "$GCLOUD" iam workload-identity-pools providers describe "$provider" --project "$project" --location global \
     --workload-identity-pool "$pool" >/dev/null 2>&1; then
  verb=update-oidc
else
  verb=create-oidc
fi
# The condition goes through a flags file: gcloud on Windows is a .cmd, which breaks on && and quotes.
flags=$(mktemp --suffix=.yaml)
trap 'rm -f "$flags"' EXIT
cat > "$flags" <<YAML
--attribute-condition: "$condition"
--attribute-mapping: "$mapping"
YAML
"$GCLOUD" iam workload-identity-pools providers "$verb" "$provider" --project "$project" --location global \
  --workload-identity-pool "$pool" --display-name "GitHub roadside-app" \
  --issuer-uri https://token.actions.githubusercontent.com --flags-file "$flags" >/dev/null

"$GCLOUD" iam service-accounts add-iam-policy-binding "$sa" --project "$project" \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/projects/$number/locations/global/workloadIdentityPools/$pool/attribute.repository_id/$repo_id" \
  --condition=None --quiet >/dev/null

suffix=DEV; [ "$environment" = production ] && suffix=PROD
cat <<OUT

Done. Repo variables (Settings → Secrets and variables → Actions → Variables):
  GCP_WIF_PROVIDER_$suffix = projects/$number/locations/global/workloadIdentityPools/$pool/providers/$provider
  GCP_DEPLOY_SA_$suffix    = $sa
  FIREBASE_PROJECT_$suffix = $project
OUT

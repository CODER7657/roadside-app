#!/usr/bin/env bash
# Launch monitoring for one project (PLAN §12.13, issue #62). Safe to re-run.
#
#   bash tool/gcp/setup_monitoring.sh <project-id> <team email> [billing account id]
#   bash tool/gcp/setup_monitoring.sh roadside-prod team@example.com 0X0X0X-0X0X0X-0X0X0X
#
# 1. An email notification channel for the team (created once, found by address after that).
# 2. Every alert policy in firebase/monitoring/*.json, sent to that channel. A policy whose display
#    name already exists is updated in place, so edit the JSON and re-run.
# 3. With a billing account (Blaze): a monthly budget of BUDGET_INR (default 500) for this project,
#    alerting at 50% (₹250) and 100% (₹500) of actual spend and at 100% of forecast spend.
#
# The Functions and SMS alerts only fire once those services run (Blaze). Needs gcloud signed in as a
# project Owner, plus Billing Account Administrator for the budget. Windows (Git Bash):
#   export PATH="$PATH:$(cygpath "$LOCALAPPDATA")/Google/Cloud SDK/google-cloud-sdk/bin" GCLOUD=gcloud.cmd
set -euo pipefail

GCLOUD=${GCLOUD:-gcloud}
project=${1:?usage: setup_monitoring.sh <project-id> <team email> [billing account id]}
email=${2:?usage: setup_monitoring.sh <project-id> <team email> [billing account id]}
billing=${3:-}
budget=${BUDGET_INR:-500}
here=$(cd "$(dirname "$0")/../.." && pwd)
policies_dir="$here/firebase/monitoring"

"$GCLOUD" services enable --project "$project" monitoring.googleapis.com logging.googleapis.com

# --- 1. Notification channel (REST: the GA gcloud has no channels command) -----------------------
token=$("$GCLOUD" auth print-access-token)
api="https://monitoring.googleapis.com/v3/projects/$project/notificationChannels"
channel=$(curl -sf -H "Authorization: Bearer $token" "$api?filter=type%3D%22email%22" |
  node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{const c=(JSON.parse(s).notificationChannels||[]).find(c=>c.labels&&c.labels.email_address===process.argv[1]);process.stdout.write(c?c.name:'')})" "$email")
if [ -z "$channel" ]; then
  body=$(node -e "process.stdout.write(JSON.stringify({type:'email',displayName:'Roadside team',labels:{email_address:process.argv[1]}}))" "$email")
  channel=$(curl -sf -X POST -H "Authorization: Bearer $token" -H 'Content-Type: application/json' -d "$body" "$api" |
    node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>process.stdout.write(JSON.parse(s).name))")
  echo "Created channel $channel ($email). Google sends that address a verification email: open it."
else
  echo "Channel $channel ($email) already exists."
fi

# --- 2. Alert policies -------------------------------------------------------------------------------
for file in "$policies_dir"/*.json; do
  name=$(node -e "process.stdout.write(require(process.argv[1]).displayName)" "$file")
  existing=$("$GCLOUD" monitoring policies list --project "$project" \
    --format='csv[no-heading](name,displayName)' | awk -F, -v n="$name" '$2==n{print $1; exit}')
  if [ -n "$existing" ]; then
    "$GCLOUD" monitoring policies update "$existing" --project "$project" --policy-from-file "$file" \
      --set-notification-channels "$channel" >/dev/null
    echo "  updated  $name"
  else
    "$GCLOUD" monitoring policies create --project "$project" --policy-from-file "$file" \
      --notification-channels "$channel" >/dev/null
    echo "  created  $name"
  fi
done

# --- 3. Budget ----------------------------------------------------------------------------------------
if [ -n "$billing" ]; then
  number=$("$GCLOUD" projects describe "$project" --format='value(projectNumber)')
  display="Roadside $project monthly"
  if "$GCLOUD" billing budgets list --billing-account "$billing" --format='value(displayName)' | grep -qx "$display"; then
    echo "Budget \"$display\" already exists; change it in the console (Billing, Budgets & alerts)."
  else
    "$GCLOUD" billing budgets create --billing-account "$billing" --display-name "$display" \
      --budget-amount "${budget}INR" --filter-projects "projects/$number" \
      --threshold-rule percent=0.5 --threshold-rule percent=1.0 \
      --threshold-rule percent=1.0,basis=forecasted-spend \
      --notifications-rule-monitoring-notification-channels "$channel" >/dev/null
    echo "Created budget \"$display\": ₹$budget a month, alerts at 50% and 100%, and at 100% forecast."
  fi
else
  echo "No billing account given: budget skipped (the project is on Spark)."
fi

#!/usr/bin/env bash
# Firestore recovery for one project (PLAN §12.13, issue #56). Safe to re-run.
#
#   bash tool/gcp/setup_backups.sh roadside-prod
#
# - Point-in-time recovery: the database can be read as it was at any minute of the last 7 days.
# - A weekly managed backup (Sunday), kept 14 weeks. Managed backups replace the "weekly export to
#   Storage" in PLAN §12.13: same purpose, no bucket or scheduler to run, restorable to a new database.
#
# Needs the Blaze plan and gcloud signed in as a project Owner. Windows (Git Bash):
#   export PATH="$PATH:$(cygpath "$LOCALAPPDATA")/Google/Cloud SDK/google-cloud-sdk/bin" GCLOUD=gcloud.cmd
set -euo pipefail

GCLOUD=${GCLOUD:-gcloud}
project=${1:?usage: setup_backups.sh <project-id>}

echo "Point-in-time recovery on $project…"
"$GCLOUD" firestore databases update --project "$project" --enable-pitr

if "$GCLOUD" firestore backups schedules list --project "$project" \
     --format='value(recurrence)' | grep -qi weekly; then
  echo "Weekly backup schedule already exists."
else
  echo "Weekly backup schedule (Sunday, kept 14 weeks)…"
  "$GCLOUD" firestore backups schedules create --project "$project" \
    --recurrence weekly --day-of-week SUN --retention 98d
fi

"$GCLOUD" firestore databases describe --project "$project" \
  --format='value(pointInTimeRecoveryEnablement,versionRetentionPeriod)'
"$GCLOUD" firestore backups schedules list --project "$project"

cat <<'OUT'

Restore (see docs/runbooks/rollback.md):
  point in time: read documents with a readTime in the last 7 days, or clone:
    gcloud firestore databases clone --source-database=projects/<p>/databases/(default) \
      --snapshot-time=<RFC 3339 time> --destination-database=restore-<date>
  backup:        gcloud firestore databases restore --source-backup=<backup name> --destination-database=restore-<date>
Restores go to a NEW database; copy back only the affected documents with a reviewed script.
OUT

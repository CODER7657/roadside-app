#!/usr/bin/env bash
# Assigns every open issue to its owner by label: P1 → @CODER7657, P2 → @Hem60, P3 → @Ayush3422.
# GitHub only accepts assignees who have access, so run this after Hem and Ayush accept their invites.
# Safe to re-run. Usage: bash tool/assign_issues.sh
set -euo pipefail
REPO="CODER7657/roadside-app"
declare -A OWNER=( [P1]=CODER7657 [P2]=Hem60 [P3]=Ayush3422 )

for label in P1 P2 P3; do
  user="${OWNER[$label]}"
  if ! gh api "repos/$REPO/assignees/$user" --silent 2>/dev/null; then
    echo "✗ $user can't be assigned yet (invite not accepted?), skipping $label"
    continue
  fi
  count=0
  for n in $(gh issue list --repo "$REPO" --label "$label" --state open --limit 200 --json number --jq '.[].number'); do
    gh issue edit "$n" --repo "$REPO" --add-assignee "$user" >/dev/null
    count=$((count + 1))
  done
  echo "✓ $label → @$user: $count issues"
done

#!/usr/bin/env bash
# Fails if the published legal pages still contain [[PLACEHOLDERS]] (PLAN §12.12, #55).
# The production deploy runs it; dev deploys don't, so drafts can be previewed on the dev site.
# Usage: bash tool/check_legal_placeholders.sh [dir]   (default: firebase/hosting/share)
set -u
dir="${1:-firebase/hosting/share}"
hits=$(grep -rnoE '\[\[[A-Z_]+\]\]' --include='*.html' "$dir" 2>/dev/null | sort -u)
if [ -n "$hits" ]; then
  echo "✗ Legal pages still have placeholders; fill them in (docs/legal/README.md) before a production deploy:"
  echo "$hits" | awk -F: '{print "  " $1 ": " $3}' | sort -u
  exit 1
fi
echo "✓ No placeholders in $dir"

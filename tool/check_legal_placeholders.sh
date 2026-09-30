#!/usr/bin/env bash
# Fails if the published legal pages are still drafts: a [[PLACEHOLDER]] left in, or the
# "Draft for review" banner (class="draft") not yet removed (PLAN §12.12, #55).
# The production deploy runs it; dev deploys don't, so drafts can be previewed on the dev site.
# Usage: bash tool/check_legal_placeholders.sh [dir]   (default: firebase/hosting/share)
set -u
dir="${1:-firebase/hosting/share}"
if [ ! -d "$dir" ]; then
  echo "✗ $dir not found"
  exit 1
fi
hits=$(grep -rnoE '\[\[[^]]+\]\]|class="draft"' --include='*.html' "$dir" 2>/dev/null | sort -u)
if [ -n "$hits" ]; then
  echo "✗ Legal pages are still drafts; fill in every placeholder and remove the draft banner (docs/legal/README.md) before a production deploy:"
  echo "$hits" | awk -F: '{print "  " $1 ": " $3}' | sort -u
  exit 1
fi
echo "✓ No placeholders or draft banners in $dir"

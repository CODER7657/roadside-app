#!/usr/bin/env bash
# Checks the Play listing text in docs/play/listing/<app>/<locale>/ against Play Console's limits (#58):
# title ≤ 30, short description ≤ 80, full description ≤ 4000 characters.
#
#   bash tool/check_store_listing.sh [listing dir]
#
# [[APP_NAME]] isn't decided yet, so it counts as APP_NAME_MAX (12) characters: the listing still fits
# once the name is filled in, as long as the name is no longer than that. Characters are Unicode code
# points, as Play counts them (a Devanagari vowel sign is one character).
set -euo pipefail

dir=${1:-docs/play/listing}
name_max=${APP_NAME_MAX:-12}
placeholder=$(printf 'N%.0s' $(seq 1 "$name_max"))
export LC_ALL=C.UTF-8

count() { # file → characters, without the final newline, with [[APP_NAME]] at its maximum length
  local text
  text=$(sed "s/\[\[APP_NAME\]\]/$placeholder/g" "$1")
  printf '%s' "$text" | wc -m | tr -d ' '
}

fail=0
checked=0
for locale_dir in "$dir"/*/*/; do
  for spec in title.txt:30 short_description.txt:80 full_description.txt:4000; do
    file="$locale_dir${spec%%:*}"
    max=${spec##*:}
    if [ ! -f "$file" ]; then
      echo "✗ missing $file"; fail=1; continue
    fi
    n=$(count "$file")
    checked=$((checked + 1))
    if [ "$n" -gt "$max" ]; then
      echo "✗ $file: $n characters (max $max)"; fail=1
    elif [ "$n" -eq 0 ]; then
      echo "✗ $file is empty"; fail=1
    fi
  done
done

if [ "$checked" -eq 0 ]; then echo "✗ no listings under $dir"; exit 1; fi
if [ "$fail" -ne 0 ]; then exit 1; fi
echo "✓ Store listing fits Play's limits ($checked fields, [[APP_NAME]] counted as $name_max characters)"

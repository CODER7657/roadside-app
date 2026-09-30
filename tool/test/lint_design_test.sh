#!/usr/bin/env bash
# Self-test for tool/lint_design.sh. Run from the repo root: bash tool/test/lint_design_test.sh
set -u
dir=tool/test/lint_design
fail=0

if ! out=$(bash tool/lint_design.sh "$dir/good"); then
  echo "✗ good fixture should pass:"; echo "$out"; fail=1
fi

if out=$(bash tool/lint_design.sh "$dir/bad"); then
  echo "✗ bad fixture should fail"; fail=1
fi
for line in 3 4 5; do
  grep -q "bad.dart:$line:" <<<"$out" || { echo "✗ padding literal on line $line not flagged"; fail=1; }
done
for message in 'Raw Color' 'Material Colors' 'TextStyle' 'fontSize' 'Magic-number SizedBox' 'Magic radius' \
  'Raw Duration' 'Hard-coded string' 'Material button' 'showDialog' 'HapticFeedback' 'print()'; do
  grep -qF "$message" <<<"$out" || { echo "✗ expected a \"$message\" finding"; fail=1; }
done

[ $fail -eq 0 ] && echo "✓ lint_design self-test passed"
exit $fail

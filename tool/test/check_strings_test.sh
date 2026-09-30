#!/usr/bin/env bash
# Self-test for tool/check_strings.dart. Run from the repo root: bash tool/test/check_strings_test.sh
set -u
dir=tool/test/check_strings
fail=0

if ! out=$(dart run tool/check_strings.dart "$dir/good"); then
  echo "✗ good fixture should pass:"; echo "$out"; fail=1
fi

if out=$(dart run tool/check_strings.dart "$dir/bad"); then
  echo "✗ bad fixture should fail"; fail=1
fi
for expected in \
  'app_en.arb: key "Title" is not snake_case' \
  'app_hi.arb: @@locale is "gu", expected "hi"' \
  'app_hi.arb: "home_title" is empty' \
  'app_hi.arb: "flow_step_label" drops the {total} placeholder' \
  'app_hi.arb: "old_screen_label" is not in app_en.arb' \
  'app_gu.arb: missing "home_title"' \
  '6 problem(s)'; do
  if ! grep -qF "$expected" <<<"$out"; then
    echo "✗ expected: $expected"; fail=1
  fi
done

if ! out=$(dart run tool/check_strings.dart "$dir/no_such_app"); then
  echo "✗ an app without ARB files should pass:"; echo "$out"; fail=1
fi

[ $fail -eq 0 ] && echo "✓ check_strings self-test passed"
exit $fail

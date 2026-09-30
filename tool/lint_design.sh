#!/usr/bin/env bash
# Fails if app code bypasses the Lane design system (PLAN.md §7.3). Runs in CI on every PR.
# Usage: tool/lint_design.sh [app_lib_dir ...]   (default: all three apps)
# Escape hatch for a justified line: add the comment  // lane-ignore
set -u
dirs=("$@")
[ ${#dirs[@]} -eq 0 ] && dirs=(customer_app/lib mechanic_app/lib admin_panel/lib)
fail=0

check() { # $1 = regex, $2 = message
  local hits
  hits=$(grep -rnE --include='*.dart' "$1" "${dirs[@]}" 2>/dev/null \
    | grep -v '/_local_ui/' | grep -v '\.g\.dart' | grep -v '\.freezed\.dart' | grep -v 'lane-ignore')
  if [ -n "$hits" ]; then
    echo "✗ $2"
    echo "$hits" | head -20
    echo
    fail=1
  fi
}

check 'Color\(0x'                                             'Raw Color(0x…): use context.lane.color.*'
check '\bColors\.[a-z]'                                       'Material Colors.*: use context.lane.color.*'
check '\bTextStyle\('                                         'TextStyle(…): use context.lane.text.*'
check 'fontSize:'                                             'fontSize: use a Lane text style'
# A digit that starts a number (not the 4 in lane.space.s4).
check 'EdgeInsets\.(all|only|symmetric)\(([^)]*[^A-Za-z0-9_.])?[0-9]' 'Magic-number padding: use lane.space.*'
check 'SizedBox\((height|width): *[0-9]'                      'Magic-number SizedBox: use Gap(lane.space.*)'
check 'BorderRadius\.circular\( *[0-9]'                       'Magic radius: use lane.radius.*'
check 'Duration\(milliseconds:'                               'Raw Duration in UI: use lane.motion.*'
check 'Text\( *['"'"'"]'                                      'Hard-coded string: use AppLocalizations'
check '\b(ElevatedButton|FilledButton|OutlinedButton|TextButton)\(' 'Material button: use LaneButton.*'
check '\bshowDialog\('                                        'showDialog: use LaneSheet / LaneConfirmSheet'
check 'HapticFeedback\.'                                      'HapticFeedback: use LaneHaptics.*'
check '\bprint\('                                             'print(): use LaneLog (redacts PII)'

[ $fail -eq 0 ] && echo "✓ Lane design lint passed"
exit $fail

## What & why
<!-- One feature per PR. Link the issue: Closes #__ -->

## Screenshots / recording (required for UI)

## Definition of Done (PLAN.md §7.9)
- [ ] Uses one Lane template and Lane components only; `tool/lint_design.sh` passes
- [ ] All strings in ARB (en/hi/gu)
- [ ] loading / empty / error / offline states done
- [ ] Widgetbook use-case + golden test added
- [ ] Checked at 200% text, TalkBack labels present
- [ ] Day / Night / Glare / Saver checked on device
- [ ] `flutter analyze` 0 warnings; tests pass
- [ ] No new Firestore field or status outside PLAN.md §8–9

## Security (PLAN.md §12.14): tick if this PR touches data, auth, files or functions
- [ ] No secrets, keys or keystores added
- [ ] New/changed fields added to §8, rules, rule tests, Dart + TS models
- [ ] Client writes limited with `hasOnly` / `affectedKeys`
- [ ] Callable: auth + role + zod + App Check + rate limit + safe errors
- [ ] No PII in logs, analytics or crash reports

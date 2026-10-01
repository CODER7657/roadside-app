# Staged rollout (PLAN §14, #61)

How v1.0.0 (and later releases) go from the closed test to everyone, and when to stop.

## Order

1. **Mechanic app first, to 100%.** Mechanics are a small known group (about 20 at launch, #64). A 10%
   rollout would leave most of them without the app and starve dispatch. Release it to production at
   100% once the closed test is clean, and help every onboarded mechanic install it and go online.
2. **Customer app, staged:** 10% → 50% → 100%, with the gates below.
3. **Cities:** start with **Ahmedabad** only (A6 → service areas), and open **Ankleshwar** and **Bharuch**
   once each has enough approved mechanics online at launch hours (#64). A booking outside an active
   area gets the "not in your area yet" screen, so this is safe at any rollout percentage.

## Gates

Check all of them before each step. **Any gate failing = halt** (Play Console → Production → Halt
rollout), then follow `rollback.md` or `hotfix.md`.

| Gate | Threshold | Where |
| --- | --- | --- |
| Crash-free users | ≥ 99.5% | Firebase → Crashlytics (per app, this version) |
| User-perceived ANR rate | < 0.47% | Play Console → Android vitals (Google's bad-behaviour threshold) |
| OTP sign-in success | ≥ 70% | A1 dashboard / Authentication → Usage |
| P0 bugs | none open | GitHub issues labelled `P0` (booking, payment, safety or data exposure broken) |
| Alerts | none unresolved | `launch-monitoring.md` |

Low numbers: with very few users, one crash can swing the rate. If fewer than 50 people have used the
new version, hold longer rather than decide on noise.

## Schedule (customer app)

| Step | Hold | Then |
| --- | --- | --- |
| 10% | at least 24 h | gates pass → 50% |
| 50% | at least 24 h | gates pass → 100% |
| 100% | first week | the daily check-in in #62 |

Updates after launch use the same steps; a hotfix may go 20% → 100% (`hotfix.md`).

## Release notes

`docs/play/release-notes/<app>/<locale>.txt` (en-IN, hi-IN, gu), at most 500 characters each, checked
by `tool/check_store_listing.sh`. Update them for every release in the release PR; the hi and gu text
goes through the same native-speaker review as the listing.

## Rollout log (fill in during the release, in the #61 PR)

| Date and time (IST) | App | Version | Step | Crash-free | ANR | OTP success | Decision |
| --- | --- | --- | --- | --- | --- | --- | --- |
| | mechanic | 1.0.0 | 100% | | | | |
| | customer | 1.0.0 | 10% | | | | |
| | customer | 1.0.0 | 50% | | | | |
| | customer | 1.0.0 | 100% | | | | |

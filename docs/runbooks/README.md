# Runbooks (PLAN §12.12, §12.13)

What to do when something goes wrong in production. Each runbook starts with the first 15 minutes,
then the follow-up. Keep them short enough to follow on a phone.

| Runbook | Use it when |
| --- | --- |
| [breach.md](breach.md) | Personal data may have reached someone who shouldn't have it |
| [sms-abuse.md](sms-abuse.md) | OTP SMS volume or cost jumps, or the SMS success rate drops |
| [dispatch-outage.md](dispatch-outage.md) | Bookings aren't reaching mechanics, or the apps can't book |
| [rollback.md](rollback.md) | A release (app, functions or rules) is causing harm |
| [hotfix.md](hotfix.md) | A fix must reach production without the unreleased work on `main` |
| [app-check-and-monitoring.md](app-check-and-monitoring.md) | Setting up or enforcing App Check, Crashlytics, Performance (#48) |

## Who does what

| Role | Who | Owns |
| --- | --- | --- |
| Incident lead | P3 · Ayush (@Ayush3422) | Declares the incident, runs the runbook, writes the report |
| Apps | P1 · Pavan (@CODER7657) | Customer app, `lane_ui`; Play Console releases with P3 |
| Backend | P2 · Hem (@Hem60) | Mechanic app, Cloud Functions |
| Client | Operator (see #71) | Data fiduciary: signs off notices to users and the Board, runs the support phone |

If the incident lead can't be reached in 15 minutes, whoever noticed takes the lead.

## Every incident

1. Post in the team group: **what** you see, **since when**, **who is affected**, and "I'm leading".
2. Open a GitHub issue labelled `incident`. Booking IDs and uids only: no names, numbers or addresses.
3. Keep a timeline in the issue: times in IST, what was done and by whom.
4. Afterwards: a short report in the issue (cause, impact, fix, what stops it happening again) and a
   follow-up issue for each action.

## Levers

- **Admin console → Settings (A6):** `dispatchEnabled` (kill switch), `maintenanceMessage`,
  `minSupportedBuild` (force update), each city's service area on or off.
- **Admin console → Live bookings (A3):** cancel a booking with a reason.
- **Admin console → Approvals (A2):** block a mechanic (signed out everywhere within the hour).
- `tool/admin/admins.mjs revoke <email>`: remove an admin and end their sessions.
- **Firebase console:** App Check enforcement, the Auth SMS region policy, sign-in providers on or off.
- **Play Console:** halt a staged rollout.
- **GitHub Actions:** redeploy Firebase from an earlier tag ([rollback.md](rollback.md)).

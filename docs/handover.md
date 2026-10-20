# Client handover (PLAN §18, #71)

Everything the client needs to own and run the service after day 20. Fill in the blanks at handover
and have the client sign the checklist at the end. **No passwords, keys or tokens in this file**: it says
where they are, not what they are.

## 1. Accounts

| Service | What it runs | Registered to | Owner / admins at handover | Billing |
| --- | --- | --- | --- | --- |
| Google Play Console | Both apps, listings, releases | The client (#43) | Client owner; team as admins until support ends | One-time fee, paid from the year-1 package |
| Firebase / Google Cloud `roadside-prod` | Production: sign-in, database, files, functions, hosting | Client's Google account | Client owner; team as editors until support ends | Blaze, on the team's card for year 1 (§18) |
| Firebase / Google Cloud `roadside-33282` | Development and testing | Team | Team (can be deleted or transferred after support) | Spark (free) |
| Ola Maps | Maps and addresses in the apps | ______ | ______ | Free tier (100K events a month) |
| GitHub `CODER7657/roadside-app` | Source code, CI, deploys | Team | Transferred to the client after the final payment (§3) | Free |
| Share and legal pages | `https://<prod share site>/privacy/`, `/terms/`, `/delete-account/`, trip links | Firebase Hosting (`*.web.app`) | With `roadside-prod` | Free; a custom domain is optional (≈ ₹800–1,200 a year, not included) |
| Team mailbox for alerts | Monitoring and budget alerts (#62), Crashlytics | ______ | ______ | — |
| Grievance mailbox | `[[GRIEVANCE_EMAIL]]`: privacy requests, web deletion requests | Client | Client | — |

## 2. Where secrets live

| Secret | Where | Who can reach it |
| --- | --- | --- |
| Android **upload keystore** and its passwords | The client's password manager (never in git or CI logs) | Client; a GitHub `production` secret for `release-android.yml` |
| Play App Signing key | Google (Play App Signing) | Nobody downloads it |
| Deploy access from GitHub | **No keys**: Workload Identity (`tool/gcp/setup_deploy.sh`, #41) | Only this repo's workflows, in their GitHub environment |
| Firebase web / Android config | In the apps and the `ADMIN_WEB_ENV` variable; identifies the project, not secret; the API keys are restricted (#42) | — |
| Admin access to the console | Google accounts on the allow-list, with 2-step verification; managed with `tool/admin/admins.mjs` | Repo owner / P3 |

## 3. Admin users and training

- [ ] Admin accounts for client staff: `node tool/admin/admins.mjs grant <email> --project roadside-prod --allow-prod`,
      then again after their first sign-in. List: `... list`. Remove: `... revoke <email>`.
- [ ] 30-minute console training, **recorded**, covering:
  - A1 dashboard (the daily numbers, city filter)
  - A2 approvals (the checklist in `docs/supply-onboarding.md`, the verification call)
  - A3 live bookings (cancel a stuck booking)
  - A4 prices, A5 complaints and reviews, A6 settings (kill switch, maintenance message, force update,
    service areas)
  - What to do when something goes wrong: `docs/runbooks/` (dispatch outage and breach first)
- [ ] The client knows who to call in the team during the 1-month support period, and after it.

## 4. Costs and dates

| Item | |
| --- | --- |
| Production launch date | ______ |
| Year-1 platform package ends | ______ (12 months after launch) |
| Year-2 quote sent by | ______ (1 month before the package ends) |
| Year-2 running costs at the same scale | ≈ ₹7,500–15,000 a year (Firebase, OTP SMS, maps) |
| Budget alerts | ₹250 / ₹500 a month (`tool/gcp/setup_monitoring.sh`) |
| Bug-fix support | 1 month after launch; new features quoted separately |

Year 2: the client either moves Firebase billing to their own card (Billing → account management → change
billing account) or renews a yearly package. OTP SMS is the cost that grows with users; if logins grow a
lot, consider a DLT-registered SMS provider (PLAN §18).

## 5. Source code transfer (after the final payment)

- [ ] Transfer `CODER7657/roadside-app` to the client's GitHub account or organisation (Settings → Transfer),
      or add them as owner.
- [ ] Re-run `tool/gcp/setup_deploy.sh` if the repo's owner changes: the deploy trust is tied to the repo's
      numeric id and owner id.
- [ ] Hand over `PLAN.md`, `docs/` (runbooks, retention, security review, Play) and the design files.

## Handover checklist (client signs)

| Item | Done | Client initials |
| --- | --- | --- |
| Play Console owned by the client; both apps live | | |
| `roadside-prod` owned by the client; billing arrangement agreed | | |
| Admin accounts created; training done and recording shared | | |
| Keystore in the client's password manager | | |
| Grievance mailbox monitored; legal pages final | | |
| Costs, year-1 end date and year-2 options understood | | |
| Source code transferred (after final payment) | | |

Signed for the client: ______________ Date: ______

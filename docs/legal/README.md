# Legal pages, consent text and review (PLAN.md §12.12, #55)

Owner: P3. **These are drafts written by the development team from how the apps work. The client's
legal adviser must review them before production.**

## Where they live

| Page | Source | URL (share site) |
|---|---|---|
| Privacy policy | `firebase/hosting/share/privacy/index.html` | `https://<site>.web.app/privacy/` |
| Terms of use | `firebase/hosting/share/terms/index.html` | `https://<site>.web.app/terms/` |
| Account deletion (Google Play) | `firebase/hosting/share/delete-account/index.html` | `https://<site>.web.app/delete-account/` |

The site is the `share` hosting target (`firebase/firebase.json`): dev = `roadside-33282.web.app`,
prod = the production project's site. The pages are plain HTML with `legal.css`, no scripts and a
strict CSP (`default-src 'none'; style-src 'self'`). They deploy with every Firebase deploy.

**Production guard:** `tool/check_legal_placeholders.sh` runs in the production deploy and fails
while any `[[PLACEHOLDER]]` or "Draft for review" banner (`<p class="draft">`) remains. Dev deploys
skip it so the drafts can be previewed.

## What the client must provide

| Placeholder | What | Used on |
|---|---|---|
| `[[APP_NAME]]` | The app's public name (placeholder until the client names it, HANDOFF §4.6) | all |
| `[[LEGAL_ENTITY]]` | Legal name of the business (the data fiduciary) | all |
| `[[REGISTERED_ADDRESS]]` | Registered address | privacy, terms |
| `[[GRIEVANCE_OFFICER_NAME]]` | A named person (DPDP) | privacy, deletion |
| `[[GRIEVANCE_EMAIL]]` | A monitored mailbox; also receives web deletion requests | privacy, deletion |
| `[[SUPPORT_PHONE]]`, `[[SUPPORT_EMAIL]]` | Customer support (same as `appConfig/public.supportPhone`) | terms |
| `[[JURISDICTION_CITY]]` | Courts for disputes (e.g. Ahmedabad) | terms |
| `[[MECHANIC_FEE_TERMS]]` | Whether mechanics pay a commission or fee, and how. If none: "We don't charge mechanics a fee." | terms |
| `[[EFFECTIVE_DATE]]` | The date the policy takes effect (before the closed test, §12.12) | privacy, terms |

Replace them in the HTML, commit through a PR, and the next deploy publishes them. The same
grievance name and email must go into the apps' Help screens (`GRIEVANCE_EMAIL` in the customer
app's `env/*.json`).

## Consent text (version `2026-09-v1`)

The apps record `consent: { version, acceptedAt }` (PLAN §8). **Change the version whenever the
policy changes in a way users must agree to again**: in the policy header, in
`customer_app/lib/features/first_run/application/first_run.dart` (`kConsentVersion`) and in the
mechanic app.

**Customer app** (C4, already in `customer_app/lib/l10n/app_*.arb`, keys `consent_*` and `privacy_*`):

> We only collect what we need to send you help.
> • Your phone number, name, vehicles and any photos you add.
> • Your location, only while you book and while help is on the way.
> • You can see, correct or delete your data at any time.
> ☐ I am 18 or older ☐ I agree to the privacy notice

**Mechanic app** (proposed for P2's C4 / M1, same structure):

> We only collect what we need to send you jobs and pay you.
> • Your phone number, name, photo, city and the work you do.
> • Your ID proof (and, for independent mechanics, a selfie with it and an address proof), kept private and seen only by our verification team.
> • Your UPI ID, shown to your customers so they can pay you directly.
> • Your location while you're online and during a job, never when you're offline.
> • You can see, correct or delete your data at any time.
> ☐ I am 18 or older ☐ I agree to the privacy notice and the terms of use

Both link "Read the full notice" to `/privacy/` and "Terms" to `/terms/`.

## Google Play Data safety (for #58)

What these pages commit to, so the form matches them:

| Data type (Play) | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| Name, phone number | Yes | With the other side of a booking | App functionality, account | Required |
| Precise location | Yes (customers while booking; mechanics while online / on a job) | With the other side of a booking | App functionality | Required |
| Photos | Yes (booking, work, KYC) | Booking photos with the mechanic; KYC not shared | App functionality, fraud prevention | Booking photos optional |
| Messages (in-app chat) | Yes | With the other side of a booking | App functionality | Optional |
| Contacts (emergency contacts the user types) | Yes | No (the user's own phone sends SOS) | App functionality (safety) | Optional |
| Government ID (mechanics) | Yes | No | Fraud prevention, security | Required for mechanics |
| Financial info: UPI ID (mechanics) | Yes | With the customer who pays | App functionality | Required for mechanics |
| Crash logs, diagnostics | Yes | No | Analytics (stability) | Required |
| Device or other IDs (FCM token, App Check) | Yes | No | App functionality, security | Required |

Data is encrypted in transit: **yes**. Users can request deletion: **yes** (in-app + the deletion
page URL above). No data is sold; no advertising.

## Review checklist

- [ ] Client's legal adviser reviews privacy, terms and deletion pages (DPDP Act 2023 + Rules 2025, Consumer Protection Act 2019, IT Act)
- [ ] All placeholders filled; `bash tool/check_legal_placeholders.sh` passes
- [ ] P2 confirms the mechanic app's path to "Delete account" matches the deletion page (currently "Profile → Delete account")
- [ ] P2 confirms web deletion requests can be verified by calling or texting the registered number (support process)
- [ ] Retention periods match what #56 implements (liveLocations TTL 24 h, chat 90 days, KYC 180 days after leaving, bookings anonymised)
- [ ] Hindi and Gujarati versions of the pages, after the glossary review below (the policy must be available in the languages the app uses)
- [ ] Native-speaker review of `docs/glossary.md` and every app's `app_hi.arb` / `app_gu.arb`
- [ ] URLs entered in Play Console (privacy policy, account deletion) and the Data safety form

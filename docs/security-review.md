# Security review (PLAN §12.14, §17; #57)

First pass, 2026-09-30, against `main` at the merge of #157. Re-run before the production submission
(day 19), when the remaining items are built. Status: ✅ done and checked · 🟡 partly done · ⏳ not built yet
or waiting on another issue.

## PLAN §17 security checks

| Check | Status | Evidence |
| --- | --- | --- |
| A customer can't read another customer's booking, OTP, or any mechanic or presence document | ✅ | `firebase/rules_tests/test/bookings.test.js`, `mechanics.test.js` (96 rule tests pass on the emulator) |
| A mechanic can't read a booking before accepting, can't write status, rating or `activeBookingId` | ✅ | Same tests. Status changes only through callables |
| Workshop and independent mechanics: the independent one can't be approved without the selfie and a logged verification call | ⏳ | The A2 console enforces it in the UI (#50). The server side is `approveMechanic` + `logVerificationCall` in **#130 (P2)** |
| Callables reject calls without App Check, without auth, with the wrong role, or with extra or invalid fields | ✅ | Every callable goes through `firebase/functions/src/lib/secureCall.ts`: `enforceAppCheck`, auth, role and `mechanicStatus`, a strict zod schema (unknown fields rejected), a per-uid rate limit, safe `HttpsError` keys. `verifyStartOtp` and `confirmPayment` also consume the App Check token (replay protection) |
| Storage rejects non-images, files over 5 MB, and writes to other users' paths; KYC isn't readable by customers | ✅ | `firebase/rules_tests/test/storage.test.js` |
| No PII in Crashlytics or function logs | ✅ | `LaneLog` redaction (#154). The mechanic app reports only redacted text (#157); the customer app follows in #92. Function logs record ids only (checked the callables) |
| gitleaks clean | ✅ | Required on every PR (CI `Secret scan`) |
| API keys restricted | ⏳ | #42: restrict the browser key to the admin domain, the Android keys to package + SHA-1 |
| SMS region policy blocks non-+91 numbers | 🟡 | Allow-list India set in the dev project (#42). Test on prod: a non-+91 number must get no SMS, and the SMS alert (#62) must fire on blocked sends |
| App Check enforced on Firestore, Storage, Functions and Auth in prod | ⏳ | Plan and rollback in `docs/runbooks/app-check-and-monitoring.md`. Needs the prod project and the apps' App Check (#92 customer, #157 mechanic done) |

## Gaps found in this pass

1. **The admin sign-in allow-list isn't built.** PLAN §12.11 layer 1 is a `beforeSignIn` blocking
   function; only `assignDefaultRole` exists. Until then, the console's role-claim check (layer 2) and the
   rules (layer 3) still keep non-admins out, but any Google account can create a session. Tracked in
   **#130 (P2)**.
2. **A2's callables don't exist yet:** `approveMechanic`, `blockMechanic`, `getKycDocumentUrls` and
   `logVerificationCall`. The console calls them and shows an error today. **#130 (P2)**.
3. **`requestAccountDeletion` isn't built** (the privacy policy, the web deletion page and Play all
   promise deletion). Tracked in **#167 (P2)**; the mechanic app screen is #169.
4. **`cancelBooking` doesn't set `liveLocations.expireAt`,** so a cancelled job's track can live 48 h, not
   24 h (`docs/retention.md`).

## Follow-ups from the review of #99 (rules v1)

| Item | Outcome |
| --- | --- |
| Review `tags` accepted any values | **Fixed here:** only the 8 U14 tag codes, at most 8 (`firestore.rules`, 2 new tests) |
| Complaint `category` was free text | **Fixed here:** `payment`, `service`, `safety` or `other`, the values A5 filters on (tests updated) |
| Audit entries for direct admin writes (`prices`, `serviceAreas`, `appConfig/public`, complaint updates) are a convention, not enforced | **Needs a decision.** Recommended: a `lastAuditId` field on each admin-written document, and rules requiring `existsAfter(auditLogs/{lastAuditId})` with a matching `target`. It adds a field to PLAN §8 (a PLAN PR with P1 + P2 approval). The alternative, moving the writes behind callables, is more P2 work |
| Mechanic photo fields accept any `https://` URL | **Needs a decision.** Recommended: store Storage paths under `mechanics/{uid}/…`, as KYC does, since rules can't tell our bucket's URL from someone else's. A model change for the mechanic app (P2), `roadside_core` and A2 |
| Chat has no rate limit (client writes) | **Recommended: accept for v1.** Chat is only allowed between the two parties of an active booking; the Firestore reads-spike alert (#62) catches abuse. Revisit if it's abused |

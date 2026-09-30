# Personal data breach (DPDP Act 2023, DPDP Rules 2025)

A breach is any unauthorised access to, or disclosure, change or loss of, personal data we hold:
phone numbers, names, addresses, locations, KYC documents, UPI IDs, chat, emergency contacts.

Examples:
- a rules bug that lets one customer read another's booking
- a compromised admin account
- KYC files readable by link
- personal data in a public log or issue
- a lost laptop with an env file or a service-account key

**If in doubt, treat it as a breach.** The duty to report starts when we become aware of it.

## First hour: contain

1. Declare the incident ([README](README.md) → "Every incident"). Don't paste the leaked data anywhere.
2. Stop the leak, whichever applies:
   - **Rules bug:** redeploy the last good rules ([rollback.md](rollback.md)). If that takes too long,
     deploy deny-all for the affected collection.
   - **Admin account compromised:**
     `node tool/admin/admins.mjs revoke <email> --project roadside-prod --allow-prod`.
     Then reset that Google account's password and check its 2-step verification.
   - **Customer or mechanic account:** block mechanics in A2. Disable customers in Firebase console →
     Authentication.
   - **Key or credential leaked:** revoke it in Google Cloud console → APIs & Services → Credentials,
     then rotate it. Service-account keys shouldn't exist at all (#41). A leaked App Check debug
     token: delete it in App Check.
   - **Data in a public place** (issue, log, chat group): delete it. For GitHub, ask support to purge
     cached views.
3. Keep evidence in a private folder the client controls: the relevant `auditLogs`, Cloud Logging
   entries and Firestore documents. Don't delete logs.

## Within 24 hours: assess

Write down, in the draft security advisory (no personal data; never a public issue):
- what data, how many people, customers or mechanics or both, which cities
- when it started, when we noticed, when it was contained
- how it happened
- what harm it could cause (fraud, stalking from location data, identity misuse from KYC)

## Notify

The client is the data fiduciary and sends these. We draft them.

- **Data Protection Board of India:**
  - an intimation **without delay**
  - a detailed report **within 72 hours** of becoming aware: facts, cause, likely impact, what we did,
    and the notices sent to users

  File through the Board's online process, as the Rules require.
- **Affected users,** **without delay**, in plain language and in their app language (en/hi/gu):
  - what happened, and what data
  - the likely consequences
  - what we did
  - what they can do (for example, ignore calls asking for a start code)
  - the Grievance Officer's contact

  Send by push and to the in-app inbox, and by SMS for people who may not open the app.
- **CERT-In:** if it is also a cyber-security incident under CERT-In's directions (for example, a
  compromised account or a data leak), report it to CERT-In **within 6 hours** of noticing.

The client signs off the drafts. The incident lead keeps the sent copies in the private folder.

## Afterwards

- A rule test for the exact case that failed (`firebase/rules_tests/`), so it can't come back.
- Ask whether the data needed to exist at all (retention, PLAN §12.10).
- The report in the advisory. Update this runbook if a step was missing.

# Launch monitoring (PLAN §12.13, #62)

## Alerts

Defined as files in `firebase/monitoring/`, applied with
`bash tool/gcp/setup_monitoring.sh <project> <team email> [billing account]` (safe to re-run: it updates
policies by name). All alerts go to the team email; forward that to the WhatsApp group by hand or with
a mail rule on the team mailbox.

| Alert | Fires when | Runbook |
| --- | --- | --- |
| Functions error rate above 2% | More than 2% of calls return 5xx over 10 min, with at least 20 calls | [rollback.md](rollback.md), [dispatch-outage.md](dispatch-outage.md) |
| Dispatch sweep failing | `dispatchSweep` logs an error, or its scheduler job fails | [dispatch-outage.md](dispatch-outage.md) |
| OTP SMS abuse | More than 100 SMS in an hour, any SMS outside India, or more than 10 blocked in an hour | [sms-abuse.md](sms-abuse.md) |
| Firestore reads spike | More than 20,000 document reads in an hour (the free tier is 50,000 a day) | [rollback.md](rollback.md) |
| Budget | Monthly spend reaches ₹250 (50%) or ₹500, or is forecast to reach ₹500 | Check what grew: Billing → Reports, by service |

Notes:
- The Functions, dispatch and SMS alerts only have data once the project is on Blaze.
- There's no Google metric for the SMS **success** rate. The alert watches volume and blocked sends;
  the success rate itself is a daily check (A1 against Authentication → Usage).
- Crashlytics has its own alerts: in Firebase console → Crashlytics → ⋮ → Alert settings, turn on
  new fatal issues, regressions and velocity alerts for both apps, to the same email.
- Tune the thresholds after launch week: change the JSON, re-run the script, note it in #62.

## Launch week: daily check-in

Once a day for the first 7 days after the production release, post this in #62 (numbers only, no
personal data):

```markdown
### Day N (YYYY-MM-DD)
- Bookings: created N · completed N · no mechanic found N · cancelled N (per city: A / An / B)
- Median arrival time: N min
- Mechanics online at peak: A N · An N · B N
- Crash-free users: customer N % · mechanic N % (target ≥ 99.5 %)
- SMS: sent N · sign-ins N · success N % (healthy 70–85 %)
- Firestore reads today: N (free tier 50,000) · spend this month: ₹N
- Alerts fired: none / which, and what we did
- Complaints: N new, N resolved
- Rollout: N % → next step (#61)
- Action items:
```

Where each number comes from:
- **Bookings, arrival, mechanics online, complaints:** admin console A1 (city filter).
- **Crash-free users:** Firebase console → Crashlytics, per app.
- **SMS:** Authentication → Usage (SMS sent, sign-ins).
- **Reads:** Firestore → Usage.
- **Spend:** Billing → Reports.

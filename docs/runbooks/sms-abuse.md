# SMS abuse (OTP pumping)

Bots request OTP SMS to premium or foreign numbers, or in bulk, and we pay for every message.

- Normal sign-in success is roughly 70–85 %. **Below 50 % means abuse** (PLAN §12.1).
- Phone sign-in SMS need the Blaze plan. On Spark only the test numbers work.

## Signs

- The SMS success rate drops (Firebase console → Authentication → Usage; A1 doesn't show it).
- Firebase console → Authentication → Usage shows a spike in SMS sent without matching sign-ins.
- A budget alert fires (the thresholds set on Blaze in #42).
- Many sign-in attempts to numbers outside +91, or to runs of consecutive numbers.

## First 15 minutes

1. Declare the incident.
2. **Region policy:** Firebase console → Authentication → Settings → SMS region policy must be
   **Allow: India** only. Fix it now if it isn't: this stops almost all international pumping.
3. **App Check on Authentication:** App Check → APIs → Authentication → **Enforce**, if it isn't
   already. Scripts that aren't our app can then no longer request codes.
4. Costs still climbing? Switch off the **Phone** sign-in provider (Authentication → Sign-in method):
   - Existing sessions keep working; new sign-ins stop.
   - Set a `maintenanceMessage` in A6 saying sign-in is paused.
   - Tell the client's support phone.

## Next

- Cloud Logging: which numbers or prefixes, and did the requests carry App Check tokens? If they did,
  a real device or a leaked debug token is being used. Delete any debug tokens you don't recognise.
- Lower the per-IP SMS quota if the console offers one for the project.
- If the requests come through our apps (valid App Check), ask Hem for a rate limit per device and per
  phone number before sending the code, and look for a pattern in one account's traffic.
- Switch the Phone provider back on once App Check enforcement and the region policy are confirmed.
  Watch the success rate for an hour.
- Ask Google Cloud billing support about charges from confirmed fraud.

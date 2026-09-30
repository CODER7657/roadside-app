# App Check, Crashlytics, Performance: setup and enforcement (PLAN §12.3, §12.13)

Owner: P3. Issue #48. The apps wire this in their own bootstrap: customer app #92 (P1), mechanic app #120 (P2).

## Providers

| Client | dev (`roadside-33282`) | prod (`roadside-prod`) |
| --- | --- | --- |
| Customer and mechanic apps (Android) | Debug provider (each member's token) | Play Integrity |
| Admin console (web) | reCAPTCHA v3 (free) on the hosted console; debug provider on `localhost` | reCAPTCHA Enterprise (needs Blaze) |
| Emulators | Off: the emulators don't check App Check | — |

Debug tokens are secrets: they go in the Firebase console and in git-ignored env files only, never in
git, chat, issues or CI logs.

## 1. Register your debug tokens (every member, once per device or browser)

**Android (dev flavour).** The app activates App Check with the debug provider in `dev`:

```dart
await FirebaseAppCheck.instance.activate(
  providerAndroid: flavor == AppFlavor.prod
      ? const AndroidPlayIntegrityProvider()
      : const AndroidDebugProvider(),
);
```

Run the dev build once, then find the token in logcat:

```bash
adb logcat | grep -i "DebugAppCheckProvider"
```

It prints `Enter this debug secret into the allow list in the Firebase Console for your project: <token>`.
Register it in **Firebase console → App Check → Apps → (the Android app) → ⋮ → Manage debug tokens → Add**,
named `<you>-<device>` (for example `pavan-pixel7`). The token is stored in the app's data, so it stays the
same until you clear the app's storage or reinstall.

**Admin console on localhost.** Set `"APP_CHECK": "debug"` in `admin_panel/env/dev.json` (git-ignored), run the
panel, and copy the token the browser console prints (`Firebase App Check debug token: …`). Register it
under the **web** app the same way. To keep the same token across browsers, put it in
`APP_CHECK_DEBUG_TOKEN` in the same env file. Release builds ignore `debug` (and the token): env values are compiled into
the public JavaScript, so a deployed console never carries a debug provider.

When a device is lost or someone leaves the team, delete their tokens from the same screen.

## 2. The hosted admin console: reCAPTCHA

1. **dev (reCAPTCHA v3, free):** at <https://www.google.com/recaptcha/admin/create> create a **v3** key, label
   `roadside-33282-admin`, with the domain `roadside-33282-admin.web.app`.
2. In **Firebase console → App Check → Apps → (web app) → reCAPTCHA**, paste the **secret key**. Token TTL: 1 hour.
3. Add these to the `ADMIN_WEB_ENV` variable of the GitHub `development` environment (the site key is public):
   `"APP_CHECK": "v3"` and `"RECAPTCHA_SITE_KEY": "<site key>"`.
4. **prod:** reCAPTCHA Enterprise, on the prod project once it's on Blaze. Use `"APP_CHECK": "enterprise"` and
   the Enterprise site key.

The console's CSP (`firebase/firebase.json`) already allows `www.google.com/recaptcha/` and
`www.gstatic.com/recaptcha/`; `admin_panel/web/firebase_sdk.js` loads the App Check SDK.

## 3. Turning on enforcement

Enforcement means Firebase rejects every request without a valid App Check token. Turn it on per
service in **App Check → APIs**, in this order: Firestore, then Authentication, then (on Blaze) Storage. Callable
functions already set `enforceAppCheck: true` in code (PLAN §12.6).

| Project | When | Condition |
| --- | --- | --- |
| dev | by day 6 | For 48 hours, the metrics show **only verified requests** (no "unverified: invalid" or "outdated client"). |
| prod | before the production submission (day 19) | Same, measured on the closed-test build. |

Before switching a service on:

1. Open **App Check → APIs → (service) → metrics**, last 7 days.
2. "Unverified: outdated client" means someone runs an old build without App Check: update it first.
3. "Unverified: invalid" in dev means an unregistered debug token: find out whose.
4. Tell the team in the group, switch it on, and watch the metrics for an hour. Apps without a valid token
   now get `permission-denied`.

**Rollback:** the same screen, **Unenforce**. It takes effect within minutes. Say so in the group and in #48.

## 4. Crashlytics (Android apps)

`LaneLog` already redacts phone numbers, OTPs, addresses, coordinates, names and UPI IDs in release builds.
Send it to Crashlytics once in `bootstrap`, after `Firebase.initializeApp` and App Check:

```dart
final crashlytics = FirebaseCrashlytics.instance;
await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
LaneLog.redact = true; // also in profile builds, since they report too
LaneLog.sink = LaneLog.crashReporterSink(
  log: crashlytics.log,
  recordError: (error, stack) => crashlytics.recordError(error, stack),
);
FlutterError.onError = (details) {
  LaneLog.e('flutter error', error: details.exception, stackTrace: details.stack);
};
```

- Report errors only through `LaneLog`: `crashReporterSink` sends a `RedactedError` holding the redacted
  text, never the original exception. Don't call `recordError` or `recordFlutterFatalError` directly,
  and don't call `setUserIdentifier` or `setCustomKey` with personal data. The `uid` is fine.
- Release builds are obfuscated (PLAN §12.7), so upload the symbols or the stack traces are unreadable:

  ```bash
  firebase crashlytics:symbols:upload --app=<android app id> build/symbols
  ```

- Target: crash-free users ≥ 99.5 %. Check the dashboard after every closed-test release.

The admin console is web-only, which Crashlytics doesn't support. It logs to the browser console.

## 5. Performance Monitoring and Remote Config

- **Performance:** add `firebase_performance` to both apps. App start and screen rendering are measured
  automatically. Add custom traces only around dispatch (`createBooking` until the first offer) and never
  put personal data in trace attributes.
- **Remote Config:** not used yet. Kill switches, the maintenance message and force update live in
  `appConfig/public` (Firestore, PLAN §8), which the admin console edits (A6). Add Remote Config only for
  staged feature flags, and never for security decisions.

## Checklist for #48

- [ ] Every member's debug token registered in dev (P1, P2, P3, each device)
- [ ] reCAPTCHA v3 key for the dev admin console, secret in App Check, site key in `ADMIN_WEB_ENV`
- [ ] Customer app (#92) and mechanic app (#120) activate App Check and send `LaneLog` to Crashlytics
- [ ] dev: Firestore and Auth enforced by day 6 once metrics show only verified requests
- [ ] prod: Play Integrity linked (SHA-256 of the app signing key), enforced before day 19

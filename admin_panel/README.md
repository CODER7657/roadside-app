# admin_panel

The Roadside console (PLAN.md §10 admin, §12.11): Flutter web on Firebase Hosting, Night
"control room" by default, admins only. Owner: P3.

## Who gets in

Four layers (PLAN §12.11):

1. **Sign-in gate:** Google sign-in only. The `beforeSignIn` blocking function (Functions) rejects
   any email that isn't in `adminAllowlist/{email}`.
2. **Role claim:** the panel shows nothing until the ID token has `role: admin` **and** the
   account signed in with Google. Everyone else sees "Not authorised" and is signed out
   (`lib/features/auth/application/admin_session.dart`).
3. **Rules and callables** check the same claim.
4. **Accounts:** admins use Google 2-step verification. Grant and revoke only with
   `tool/admin` (below); both are audited.

## Run it locally (no Firebase project needed)

```bash
# 1. emulators (from firebase/)
firebase emulators:start --project demo-roadside --only auth,firestore
# 2. panel against the emulators
cd admin_panel
cp env/example.json env/dev.json        # USE_EMULATORS=true
flutter run -d chrome -t lib/main_dev.dart --dart-define-from-file=env/dev.json
# 3. sign in once with the emulator's fake Google account, then make it an admin
npm ci --prefix ../tool/admin
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
  GCLOUD_PROJECT=demo-roadside node ../tool/admin/admins.mjs grant you@example.com
# 4. sign in again
```

For the dev project (`roadside-33282`) / `roadside-prod`, fill `env/dev.json` / `env/prod.json` with the web app's
config (`USE_EMULATORS=false`). The files are git-ignored. Deploys build from the
`ADMIN_WEB_ENV` environment variable instead (`.github/workflows/deploy-firebase.yml`).

App Check (PLAN §12.3): `APP_CHECK` is `v3` (dev), `enterprise` (prod), `debug` (localhost against a real
project) or empty for off, with `RECAPTCHA_SITE_KEY` for the reCAPTCHA modes and an optional
`APP_CHECK_DEBUG_TOKEN`. Setup and enforcement: `docs/runbooks/app-check-and-monitoring.md`.

## Admins

```bash
npm ci --prefix tool/admin
npm --prefix tool/admin run grant  -- ops@example.com --project roadside-33282
npm --prefix tool/admin run revoke -- ops@example.com --project roadside-33282
npm --prefix tool/admin run list   -- --project roadside-33282
```

`grant` allow-lists the email; after that person's first Google sign-in, run it again to give
the role. `roadside-prod` needs `--allow-prod`. Self-test on the emulators (from `firebase/`):
`firebase emulators:exec --project demo-roadside --only auth,firestore "node ../tool/admin/selftest.mjs"`.

## Hosting and the CSP

`firebase/firebase.json` serves `build/web` as the `admin` target with a strict
Content-Security-Policy, `X-Robots-Tag: noindex`, `X-Frame-Options: DENY` and friends.

- **No inline scripts.** `web/firebase_sdk.js` loads the Firebase JS SDK, then Flutter, so
  FlutterFire doesn't inject its inline loader. Adding a Firebase service to the panel means
  adding its bundle there. `test/firebase_sdk_version_test.dart` fails when a plugin upgrade
  changes the SDK version.
- Build with `--no-web-resources-cdn` so CanvasKit and fallback fonts come from our own origin.
- Maps (A3, #53) and App Check's reCAPTCHA (#48) need their domains added to the CSP.

## Layout

```
lib/
├── main.dart / main_dev.dart / main_prod.dart
├── app/            bootstrap, env, flavour, router (A0 outside, A1–A6 inside ConsoleShell)
├── features/
│   ├── auth/       AdminAuth (Google), session gate, A0 sign-in
│   ├── approvals/  A2 mechanic approvals (per-type checklist, admin callables #130, signed URLs)
│   ├── bookings/   bookings / presence / live-location reads, admin cancel
│   ├── complaints/ A5 complaints (resolve + audit) and reviews
│   ├── console/    sections A1–A6, city filter, enum labels
│   ├── dashboard/  A1 stat cards (IST day) and the day's bookings
│   ├── live/       A3 live bookings: schematic map, list, vertical rail, admin cancel
│   └── prices/     A4 price editor (defaults + per-city overrides, audited batch save)
├── l10n/           en / hi / gu
└── _local_ui/      ConsoleShell, PriceRangeField, StatCard, SchematicMap: until lane_ui has them
```

Before every PR: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`,
`bash ../tool/lint_design.sh lib`.

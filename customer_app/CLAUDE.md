# customer_app — P1 (@CODER7657)

Read the root `CLAUDE.md` first; this adds customer-app rules.

- Run: `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json` (copy `env/example.json` to `env/dev.json`; it's git-ignored). Flavours `dev`/`prod` live in `android/app/build.gradle.kts`; `applicationId` is a placeholder until the client confirms the package.
- Firebase (`flutterfire configure` per flavour, App Check, Crashlytics, Remote Config) lands in #92, after #42; wire it in `lib/app/bootstrap.dart`.
- Routes in `lib/app/router.dart`; strings in `lib/l10n/app_{en,hi,gu}.arb` (run `flutter gen-l10n`; `test/app_test.dart` checks the three files have the same keys).
- Screens: C1–C10 and U1–U18 (+ U1·SOS, U1·Area) in `wireframes/Wireframes.pdf`. One Lane template per screen (PLAN §6.13).
- Folder layout: `lib/app/`, `lib/features/<feature>/{data,application,presentation}/`, `lib/l10n/`, `lib/_local_ui/`.
- Data: read bookings/liveLocations/prices/serviceAreas; **write only** your own `users/{uid}` fields, vehicles, emergency contacts, reviews, chat messages. Everything else goes through callables (`createBooking`, `cancelBooking`, `markPaid`, …).
- TrustPass has two variants (PLAN §10.0): **workshop** (shop name, "Verified workshop") and **independent** ("Verified independent mechanic · N yrs" + travel-vehicle PlateChip), chosen from `booking.mechanicCard.mechanicType`. Customers never choose a type.
- Location: `LocationAccuracy.best`, wait ≤20 m or 15 s, accuracy badge; handle denied / denied-forever / GPS off.
- Maps: Ola Maps key from `--dart-define-from-file=env/dev.json` (git-ignored). Keep the pickup pin above the dock.
- SOS opens the SMS composer (no SEND_SMS permission). OTP auto-fill via SMS Retriever (no SMS permission).
- Before every PR: `dart format .`, `flutter analyze` (0 warnings), `flutter test`, `bash ../tool/lint_design.sh lib`.

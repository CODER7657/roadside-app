# customer_app — P1 (@CODER7657)

Read the root `CLAUDE.md` first; this adds customer-app rules.

- Create with `flutter create --org <client.package> --platforms android customer_app` (this file survives), then flavours `dev`/`prod` (`main_dev.dart`, `main_prod.dart`), `flutterfire configure` per flavour.
- Screens: C1–C10 and U1–U18 (+ U1·SOS, U1·Area) in `wireframes/Wireframes.pdf`. One Lane template per screen (PLAN §6.13).
- Folder layout: `lib/app/`, `lib/features/<feature>/{data,application,presentation}/`, `lib/l10n/`, `lib/_local_ui/`.
- Data: read bookings/liveLocations/prices/serviceAreas; **write only** your own `users/{uid}` fields, vehicles, emergency contacts, reviews, chat messages. Everything else goes through callables (`createBooking`, `cancelBooking`, `markPaid`, …).
- Location: `LocationAccuracy.best`, wait ≤20 m or 15 s, accuracy badge; handle denied / denied-forever / GPS off.
- Maps: Ola Maps key from `--dart-define-from-file=env/dev.json` (git-ignored). Keep the pickup pin above the dock.
- SOS opens the SMS composer (no SEND_SMS permission). OTP auto-fill via SMS Retriever (no SMS permission).
- Before every PR: `dart format .`, `flutter analyze` (0 warnings), `flutter test`, `bash ../tool/lint_design.sh lib`.

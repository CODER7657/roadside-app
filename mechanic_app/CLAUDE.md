# mechanic_app — P2 (Hem)

Read the root `CLAUDE.md` first; this adds mechanic-app rules.

- Create with `flutter create --org <client.package> --platforms android mechanic_app` (this file survives), flavours `dev`/`prod`, `flutterfire configure` per flavour.
- Screens: C1–C10 and M1–M9 in `wireframes/Wireframes.pdf`, on Lane templates. Big targets: critical actions 64 dp, slide-to-accept/finish (gloves).
- Registration splits on **"Do you have a workshop?"** (PLAN §10.0): workshop path (shop name/address/photo) vs **independent path M1·Ind** (profile photo, base area, experience, ≥2 toolkit photos, travel vehicle + plate, selfie holding ID, address proof). Everything after approval is identical for both types.
- Writes allowed from the app: own `mechanics/{uid}` editable fields, `mechanics/{uid}/private/kyc` once while pending, `presence/{uid}` (isOnline, location, updatedAt), `liveLocations/{bookingId}` while assigned, chat. **Status changes only via callables** (`respondToOffer`, `startTrip`, `markArrived`, `verifyStartOtp`, `completeJob`, `confirmPayment`, `cancelBooking`).
- Location: idle online → presence every 60 s / 100 m; active job → foreground service (type `location`) every 5 s / 10 m. Never request background location.
- Offers: high-priority FCM, `offers` notification channel with sound, full-screen intent; no exact address before accept.
- Android 16: Live Update (ProgressStyle) mirroring the Journey Rail; fallback ongoing notification.
- Before every PR: `dart format .`, `flutter analyze`, `flutter test`, `bash ../tool/lint_design.sh lib`.

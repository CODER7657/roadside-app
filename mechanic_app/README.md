# mechanic_app

The Roadside mechanic app (P2). Rules: `CLAUDE.md` here and at the repo root; the plan is `PLAN.md`.

## Run

```bash
cp env/example.json env/dev.json   # git-ignored; fill in what you have
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

Without Firebase config the app still starts and runs on its in-memory fakes (as in tests and CI).

## Firebase (#120)

| Flavour | Project | Android app id | Config file (git-ignored) |
|---|---|---|---|
| dev | `roadside-33282` | `com.roadside.mechanic.dev` | `android/app/src/dev/google-services.json` |
| prod | `roadside-prod` (not created yet, #42) | `com.roadside.mechanic` | `android/app/src/prod/google-services.json` |

1. In the Firebase console of the project, add an Android app with the id above (plus the
   debug SHA-1 from `cd android && ./gradlew signingReport`, needed for phone login in #123),
   and download `google-services.json` into the flavour's folder. `flutterfire configure` does
   the same; don't commit what it writes (`.gitignore` covers it).
2. **App Check** (PLAN §12.3): dev uses the debug provider. On the first run, logcat prints
   `Enter this debug secret into the allow list in the Firebase Console`; add it under
   App Check → Apps → Manage debug tokens, and put it in `env/dev.json` as
   `APP_CHECK_DEBUG_TOKEN` so it stays the same. Prod uses Play Integrity.
3. **Crashlytics** reports from release builds only, through `LaneLog`, redacted (no phone
   numbers, OTPs, addresses or coordinates). To check it end to end:

   ```bash
   # with "CRASHLYTICS_TEST": "true" in env/dev.json
   flutter run --release --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
   ```

   A non-fatal "crashlytics test report" shows up in Crashlytics a few minutes later.
4. **Remote Config** defaults live in `lib/app/remote_flags.dart` (`min_supported_build`,
   `live_update_enabled`); the app works with them if Remote Config is unreachable.

## Login (#123)

C5–C6 use Firebase phone auth (India only). In dev, use the project's **test phone numbers**
(Authentication → Sign-in method → Phone): no SMS is sent and the fixed code works. Android
fills a real code in by itself (SMS Retriever, no SMS permission). Without Firebase config the
app starts signed in on its fakes; signed out, the fake takes `123456`.

Once signed in, registration, presence, offers, the job and live location use Firestore,
Storage and the callables; without Firebase they stay on the in-memory fakes.

## Emulators

The dev project is on the free plan, so Functions and Storage only run on the emulators
(`firebase/CLAUDE.md`). Set `"USE_EMULATORS": "true"` in `env/dev.json`, start the emulators
from `firebase/`, forward their ports to the phone, and run as usual:

```bash
firebase emulators:start --project demo-roadside
adb reverse tcp:8080 tcp:8080 && adb reverse tcp:5001 tcp:5001 && adb reverse tcp:9099 tcp:9099 && adb reverse tcp:9199 tcp:9199
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

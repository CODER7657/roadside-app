# P2 guide: mechanic app + Cloud Functions (Hem)

This guide goes from a fresh laptop to your final PR on day 20. Keep it open all sprint.

**You own:** `mechanic_app/` and `firebase/functions/`: the whole backend brain (dispatch, every status change, notifications). The customer app (P1) and the admin panel (P3) call your functions, so **the functions skeleton and `createBooking` land by day 2**.

---

## 1. Install the tools (day 1 morning, ~1.5 h)

Windows 11 (PowerShell as admin). On macOS use `brew` equivalents.

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Microsoft.OpenJDK.21 -e      # needed by the Firebase Emulator Suite
winget install --id Google.AndroidStudio -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Gitleaks.Gitleaks -e
```

Then:
1. **Flutter SDK (stable).**
   - In VS Code, install the *Flutter*, *Dart* and *ESLint* extensions.
   - Open the command palette, run **Flutter: New Project**, and choose **Download SDK** (to `C:\dev\flutter`, no spaces).
   - Add it to PATH.
2. **Android Studio.** Install SDK Platform 36 (Android 16), command-line tools and build-tools, and create an emulator.
3. Run these in a new terminal:
   ```powershell
   flutter doctor --android-licenses
   flutter doctor
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   gh auth login
   ```
4. **Claude Code.** Install it:
   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```
   (or `npm i -g @anthropic-ai/claude-code`), then run `claude` once to sign in.
5. **Two real Android phones** if you can: one as customer, one as mechanic. Background location and full-screen offers can only be tested on real devices.

## 2. Accounts & access (day 1)
- Accept the GitHub invite to `CODER7657/roadside-app`, turn on 2FA, and **comment your GitHub username on your "Start here" issue** so Ayush can add you to CODEOWNERS.
- Ayush adds you to the Firebase **dev** project. Register your App Check debug token (dev only, never commit it).
- Functions secrets go in Secret Manager via `defineSecret()`, never in `.env` files in git.

## 3. Get the repo and first look
```bash
git clone https://github.com/CODER7657/roadside-app.git
cd roadside-app
code .
```
Read, in order:
1. `PLAN.md` §0–§3 and §5–§7, then **§8 (data model), §9 (status flow), §11 (dispatch), §12 (security)**
2. `wireframes/Wireframes.pdf`, the mechanic page (M1–M9)
3. `CLAUDE.md`, `mechanic_app/CLAUDE.md`, `firebase/functions/CLAUDE.md`

## 4. How to use Claude Code every day
Start from the **repo root**:
```bash
cd roadside-app
claude
```
Prompt shapes that work well:
> Read PLAN.md §8, §9, §11 and §12.6. In firebase/functions, write the respondToOffer callable using our secureCall wrapper (enforceAppCheck, mechanic role, zod input, rate limit). Run it in a Firestore transaction so only one mechanic can accept. Snapshot mechanicCard/customerCard as §8 says. Add emulator tests, including two mechanics racing to accept.

> Read PLAN.md §6, §7, §10 M4 and wireframe M4. In mechanic_app, build the Incoming offer screen with LaneStatusScaffold, CountdownRing and LaneSlideToConfirm, using the full-screen intent and offers notification channel. Don't show the exact address before accept. Add ARB keys (en/hi/gu) and a golden test.

Rules of thumb:
- Review every diff.
- Never let Claude edit `packages/*`, `customer_app/`, `admin_panel/` or `PLAN.md`. Open an issue for P1 or P3 instead.
- Use `/clear` between features.

## 5. The daily loop (every issue)

**One issue = one branch = one PR.** Put exactly one `Closes #<issue>` in the PR; CI's **Linked issue** check fails otherwise, or if that issue already has a PR. Review fixes go to the same branch/PR. If an issue turns out too big, ask Ayush (P3) to split it before you start.

```bash
git switch main
git pull
git switch -c p2/<issue-number>-<short-name>
# Functions
cd firebase/functions
npm run lint
npm run build
firebase emulators:exec --project demo-roadside --only firestore,auth,functions "npm test"
# Mechanic app
cd ../../mechanic_app
dart format .
flutter analyze
flutter test
cd ..
bash tool/lint_design.sh mechanic_app/lib
git add -A
git commit -m "feat: respondToOffer with single-winner transaction"
git push -u origin HEAD
gh pr create --fill          # + screenshots, "Closes #<issue>"
```
Then:
- CI must show a green **CI result**.
- Get 1 review; rules changes need Ayush.
- Squash-merge and delete the branch.

Merged Functions deploy to **dev** automatically.

## 6. Your 20 days (matches your GitHub issues)

| Days | What | Milestone |
|---|---|---|
| 1 | Functions skeleton: TS, `asia-south1`, `secureCall` wrapper, emulator + first test | Day 2 |
| 2 | `createBooking`: service area (3 cities), price with city overrides, idempotency, one active booking, OTP doc | Day 2 |
| 3–4 | `mechanic_app` scaffold (flavours, App Check, l10n, LaneApp) + common screens on lane_ui 0.1 | Day 6 |
| 4–6 | M1 registration + `onMechanicRegistered` claims, M2, M3 + presence; **dispatch v1** (offers, 30 s, 3→5→10 km, cityId, `respondToOffer`) | Day 6 |
| 7–9 | M4 incoming offer (full-screen), M5 navigate + foreground location + `markArrived`, M6 start code + `verifyStartOtp`, status notifications | Day 10 |
| 10 | **Two-phone demo** with P1 | Day 10 |
| 11–14 | M7 + `completeJob`, M8 + payments, M9, `cancelBooking` re-dispatch, ratings, Live Update notification, share links | Day 14 |
| 15–16 | Functions unit + abuse tests, mechanic QA (gloves, TalkBack, 200% text) | Day 20 |
| 17–18 | Field test in the 3 cities (NH-48 highway pickups between Ankleshwar and Bharuch) | Day 20 |
| 19–20 | Prod deploy with Ayush (tag `v1.0.0`), release AAB, final PRs | Day 20 |

## 7. Things that are easy to get wrong
- **Clients never write bookings.** If a screen needs to change status, add or extend a callable.
- Every callable: App Check, auth, role, zod `.strict()`, rate limit, `HttpsError` with a safe message. **No stack traces to clients.**
- Offers must not leak the exact address or customer phone before accept.
- Location while working: foreground service (type `location`), 5 s / 10 m. No background-location permission.
- Logs contain `uid` and `bookingId` only, never phones, OTPs or coordinates.

## 8. Final PRs and release (days 19–20)
1. All your issues closed; functions tests green; `npm audit` clean at high severity.
2. `chore: release v1.0.0` PR bumping `mechanic_app/pubspec.yaml`.
3. A repo admin tags `v1.0.0`:
   - **Deploy Firebase** ships your Functions to prod.
   - **Release Android** builds the mechanic AAB.
4. Write the dispatch notes (radius, timeouts, cross-city match) into `HANDOFF.md`.

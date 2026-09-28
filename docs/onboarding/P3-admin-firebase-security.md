# P3 guide: admin panel, Firebase, security, CI and release (Ayush, @Ayush3422)

This guide goes from a fresh laptop to your final PR on day 20. Keep it open all sprint.

**You own:**
- `admin_panel/`
- `packages/roadside_core/` (shared models)
- `firebase/` (rules, indexes, `firebase.json`, rule tests)
- `.github/`, `docs/`, `tool/`
- the Play Console, prod deploys and the security review

P1 and P2 build against your **models and rules**, so `roadside_core` + rules v1 land by day 2.

---

## 1. Install the tools (day 1 morning, ~1.5 h)

Windows 11 (PowerShell as admin). On macOS use `brew` equivalents.

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Microsoft.OpenJDK.21 -e      # Firebase Emulator Suite
winget install --id Google.Chrome -e             # Flutter Web
winget install --id Google.AndroidStudio -e      # to build/test the apps too
winget install --id Microsoft.VisualStudioCode -e
winget install --id Gitleaks.Gitleaks -e
winget install --id Google.CloudSDK -e           # gcloud: Workload Identity, budgets, TTL policies
```

Then:
1. **Flutter SDK (stable).** In VS Code, install *Flutter* + *Dart*, then run **Flutter: New Project** and choose **Download SDK** (to `C:\dev\flutter`). Add it to PATH.
2. Run these in a new terminal:
   ```powershell
   flutter doctor --android-licenses
   flutter doctor
   npm install -g firebase-tools
   firebase login
   gcloud auth login
   dart pub global activate flutterfire_cli
   gh auth login
   ```
3. **Claude Code.** Install it:
   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```
   (or `npm i -g @anthropic-ai/claude-code`), then run `claude` once to sign in.
4. **Claude Cowork** for docs, sheets and reports (privacy policy, store listing, field-test report). A password manager shared with the client for keys.

## 2. Accounts & access (day 1). You set these up for everyone
1. Accept the GitHub invite (sent to @Ayush3422) and turn on 2FA. The repo owner then runs `tool/assign_issues.sh` to assign your issues.
2. **Firebase:** create `roadside-dev` and `roadside-prod`:
   - Location **asia-south1** for Firestore, Storage and Functions. This can't be changed later.
   - Blaze plan on the team's card (year-1 platform package).
   - Budget alerts ₹250 / ₹500.
   - Add P1 and P2 to dev.
3. **Auth:**
   - Phone provider on.
   - **SMS region policy: allow India only.**
   - Test phone numbers in dev.
   - Google provider for admins.
4. **API keys:** restrict to package + SHA-1 (dev and prod) and to only the APIs each key needs.
5. **Play Console:** register it in the **client's name** (US$25 from the platform package). The client does Google's ID verification with you on day 1. Decide on a personal account (12 testers × 14 days) or an organisation account (D-U-N-S).
6. **GitHub:**
   - `.github/CODEOWNERS` already uses @Hem60 and @Ayush3422.
   - Environments `development` and `production` already exist. Put the deploy variables and signing secrets on them. Required reviewers need GitHub Enterprise for private repos, so the production gate is the **tag ruleset**: only repo admins can push `v*` tags. Ask the repo owner for the admin role if you'll cut releases.
   - Set the repo variables for deploys (step 7).
   - Check the `main` ruleset (already active: PR + 1 approval + code owners + resolved threads + required **CI result** check + squash only; admins may bypass only through a PR).
   - After the folders exist, uncomment pub/npm in `dependabot.yml`.
7. **Deploy auth, no keys:** create a Workload Identity pool + provider for GitHub and a deploy service account per project (roles: Firebase Admin, Cloud Functions Admin, Service Account User). Then set these variables in *Settings → Secrets and variables → Actions → Variables*:
   - `GCP_WIF_PROVIDER_DEV`, `GCP_DEPLOY_SA_DEV`, `FIREBASE_PROJECT_DEV`
   - `…_PROD`
8. **Signing:** create the upload keystore (keep it in the client-owned password manager). Add the `production` environment secrets `ANDROID_UPLOAD_KEYSTORE_BASE64` and `ANDROID_KEY_PROPERTIES`.

## 3. Get the repo and first look
```bash
git clone https://github.com/CODER7657/roadside-app.git
cd roadside-app
code .
```
Read, in order:
1. `PLAN.md` all of it (you are the contract keeper), especially **§8, §9, §12, §13, §14, §18**
2. `wireframes/Wireframes.pdf`, the admin pages (A1–A6)
3. `CLAUDE.md`, `admin_panel/CLAUDE.md`, `firebase/CLAUDE.md`, `packages/roadside_core/CLAUDE.md`
4. `.github/workflows/*`: you maintain CI

## 4. How to use Claude Code every day
From the **repo root**:
```bash
cd roadside-app
claude
```
Prompt shapes:
> Read PLAN.md §8 and §12.4. Write firebase/firestore.rules deny-by-default with the helpers from §12.4. Every client write must be limited with hasOnly/affectedKeys. Add Jest tests in firebase/rules_tests using @firebase/rules-unit-testing, with at least one allow and one deny per collection and role, including "customer can't read another customer's booking" and "mechanic can't write status".

> Read PLAN.md §8. Create packages/roadside_core with freezed models for every collection (including serviceAreas and cityId), the §9 status transition table, validators (E.164, Indian and BH regNo, UPI) and LaneLog, which redacts PII in release builds. Include fakes so P1 and P2 can build UI before the backend is wired.

Rules of thumb:
- Review every diff.
- Changes to `PLAN.md`, `packages/*` or rules go through PRs that the other two approve.
- Use `/clear` between features.

## 5. The daily loop (every issue)

**One issue = one branch = one PR.** Put exactly one `Closes #<issue>` in the PR; CI's **Linked issue** check fails otherwise, or if that issue already has a PR. Review fixes go to the same branch/PR. If an issue turns out too big, ask Ayush (P3) to split it before you start.

```bash
git switch main
git pull
git switch -c p3/<issue-number>-<short-name>
# rules
npm ci --prefix firebase/rules_tests
cd firebase
firebase emulators:exec --project demo-roadside --only firestore,storage "npm --prefix rules_tests test"
cd ..
# admin panel
cd admin_panel
dart format .
flutter analyze
flutter test
flutter build web
cd ..
bash tool/lint_design.sh admin_panel/lib
git add -A
git commit -m "sec: deny-by-default firestore rules with tests"
git push -u origin HEAD
gh pr create --fill
```
Then:
- CI must show a green **CI result**.
- Rules and `roadside_core` PRs need P1 + P2.
- Squash-merge.

Rules merged to `main` deploy to **dev** automatically.

## 6. Your 20 days (matches your GitHub issues)

| Days | What | Milestone |
|---|---|---|
| 1 | Repo hardening, Firebase dev+prod, SMS policy, budgets, Play Console with the client | Day 2 |
| 1–2 | `roadside_core` (models, status machine, validators, LaneLog, fakes); rules v1 + tests; seed `serviceAreas` (Ahmedabad / Ankleshwar / Bharuch) + `appConfig` | Day 2 |
| 3–6 | `tool/check_strings.dart`; Storage rules; App Check/Crashlytics/Remote Config; `admin_panel` scaffold + A2 approvals + A4 prices; **closed test: upload builds + 12 testers opted in by day 6** | Day 6 |
| 7–10 | A1 dashboard + A3 live map; support the day-10 demo | Day 10 |
| 11–14 | A5 + A6 (service areas on/off), privacy policy, terms, deletion page, glossary review, retention jobs (TTL, cleanup, deletion, PITR) | Day 14 |
| 15–16 | **Security review** (PLAN §12.14, §17), App Check enforced in prod | Day 20 |
| 17–18 | Field test in all 3 cities; store listing en/hi/gu, Data safety, FGS + full-screen-intent declarations | Day 20 |
| 19–20 | Tag `v1.0.0` (admin) → prod deploy + AABs → upload → **production submission**; handover pack | Day 20 |

## 7. Things that are easy to get wrong
- The Firestore location can't be changed after creation. Double-check `asia-south1`.
- Rules trust **custom claims**, not the `admins` collection.
- ID proofs: Storage path only, and admins see them via short-lived signed URLs.
- Budget risk (PLAN §18): about ₹2,900 covers 12 months of Firebase including OTP SMS. Watch the SMS success rate and spend weekly, and warn the team early.
- Never paste keys, keystores or service-account JSON into issues, chat or Claude.

## 8. Final PRs and release (days 19–20)
1. All issues closed; security checklist done; `main` green.
2. After P1/P2 merge their release PRs, tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The tag (admins only) starts both release workflows:
   - **Deploy Firebase** ships Functions, rules, indexes and Hosting to prod.
   - **Release Android** attaches both AABs to a draft GitHub Release.
4. Upload the AABs to Play Console, complete the listing, and submit for production.
5. Publish the GitHub release. Finish `HANDOFF.md` and the client handover (accounts, costs, year-2 renewal date).

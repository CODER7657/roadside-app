# HANDOFF: state of the project on 29 Sep 2026 (day 2)

Read this first if you're picking the project up in a new session. The source of truth is [PLAN.md](PLAN.md); this file says **where things stand and why**.

## 1. What exists

| Thing | Where | Status |
|---|---|---|
| Plan rev 2 (Lane design, security, 20 days, 3 cities, ₹25k + ₹5k) | `PLAN.md` (also `D:\brainstorm\PLAN.md`; v1 kept as `D:\brainstorm\PLAN.v1.md`) | ✅ Done |
| Client proposal (9 pages, ₹30,000 all-in year 1) | `proposal/Proposal.pdf` (source `proposal.html`, images in `proposal/img/`) | ✅ Ready to send; fill the client's name on the cover |
| Wireframes (48 frames: C1–C10, U1–U18 + U1·SOS + U1·Area + U9·Ind, M1–M9 + M1·Ind, A0–A6) | `wireframes/Wireframes.pdf`, `png/`, source `wireframes.html` | ✅ Needs client sign-off (issue for P1, Day 2) |
| Design tokens | `packages/lane_ui/lib/src/tokens/` (source of truth), mirrored in `design/tokens.json` | ✅ In `lane_ui` since #4; a test fails if the two drift |
| Assets | `assets/`: fonts (OFL), Phosphor icons (MIT), ThreeUI renders (MIT), brand marks, real OSM maps | ✅ |
| Repo process | CODEOWNERS, PR template, issue forms, CONTRIBUTING, SECURITY, `.gitattributes`, `.editorconfig`, design lint | ✅ CODEOWNERS uses @Hem60 / @Ayush3422 |
| CI/CD | `.github/workflows/`: CI (one required check **CI result**), PR hygiene, Deploy Firebase (keyless), Release Android | ✅ CI green on `main`; deploy/release skip until Firebase and signing are configured |
| Protection | Ruleset on `main` (PR, 1 approval, code owners, resolved threads, required checks **CI result**, **PR title**, **Linked issue**, squash only); **one issue = one PR** enforced by `pr-hygiene.yml`; tag ruleset (`v*` admins only); squash-only + auto-delete branches | ✅ Active |
| Backlog | 72 issues: #1–#3 "Start here" guides, then P1 = 23, P2 = 22, P3 = 27 (incl. the Start issues) across milestones Day 2 / 6 / 10 / 14 / 20 and **Launch · Live for users** (production access, staged rollout, monitoring, runbooks, supply onboarding, handover, 1-month support) | ✅ |
| Folder rules | `CLAUDE.md` in root, `customer_app/`, `mechanic_app/`, `admin_panel/`, `firebase/`, `firebase/functions/`, `packages/lane_ui/`, `packages/roadside_core/` | ✅ |
| **Lane v0.1** (P1) | `packages/lane_ui`: tokens, fonts, `LaneApp` + ambient modes, 5 templates + dock, buttons/gestures, inputs/badges, feedback states + own en/hi/gu strings, Phosphor icons + tiles; `example/`, `widgetbook/`, goldens | ✅ #79 #81 #82 #87 #88 #89 #91 (168 tests) |
| **roadside_core** (P3) | `packages/roadside_core`: freezed models for §8, status machine, validators, geo, `LaneLog`, fakes; contract test against the TS models | ✅ #90 (150 tests) |
| **Cloud Functions** (P2) | `firebase/functions`: `secureCall`, `createBooking`, `assignDefaultRole`, dispatch v1 + `respondToOffer`, status notifications + inbox | ✅ #77 #78 #80 #83, **never deployed yet** (see §4) |
| **customer_app** (P1) | Flutter app: dev/prod flavours, `LaneApp.router`, go_router + Riverpod, en/hi/gu ARB, release hardening, placeholder home | 🔄 #93; Firebase wiring is #92 (blocked by #42) |
| mechanic_app, admin_panel, Firestore rules | — | ⏳ #25 (P2), #49 (P3), #45 (P3, branch `p3/45-firestore-rules` in progress) |

## 2. Team

| | Who | Owns | Start issue |
|---|---|---|---|
| P1 | Repo owner (@CODER7657) | customer_app, lane_ui, design | #1 |
| P2 | Hem (@Hem60) | mechanic_app, Cloud Functions | #2 |
| P3 | Ayush (@Ayush3422) | admin_panel, roadside_core, Firebase, rules, CI, docs, store | #3 |

## 3. Decisions made (don't reopen them without the team)
- **Design system "Lane":** Swiss base, highway-signage legibility, Beacon amber `#FFB81C`, and signal colours with red reserved for danger. It has four ambient modes (Day / Night / Glare / Saver), the Journey Rail, the Trust Pass and the thumb dock.
- **ThreeUI is the visual source:**
  - Fonts: Onest, Instrument Serif and JetBrains Mono, plus Anek for Hindi/Gujarati.
  - Buttons: Launch → primary, Spinning Border → secondary, Gradient CTA → pill, Gradient Beam → SOS ring.
  - Backgrounds are pre-rendered stills; the apps never run WebGL.
- **Icons:** Phosphor duotone via `phosphor_flutter` (the earlier hand-drawn pictograms were replaced).
- **Maps:** Ola Maps SDK in the apps, styled Uber/Rapido-like (PLAN §6.7 map table). The mockups are rendered from real OpenStreetMap vector data (OpenFreeMap + MapLibre) with a real OSRM route (2.47 km, Bodakdev → Thaltej).
- **Launch cities:** Ahmedabad, Ankleshwar and Bharuch, as `serviceAreas/{cityId}`. There's a `cityId` on bookings, mechanics and presence; pickups outside an area get the "not in your area yet" screen. Ankleshwar and Bharuch may cross-match at 10 km.
- **Security model:**
  - All status changes go through callables.
  - App Check is enforced.
  - SMS region policy is India only.
  - Offers hide the address until accept.
  - OTP has 5 attempts, then a lock.
  - TTL and retention per §12.10.
  - Built for DPDP.
  - Keyless deploys.
- **Money:**
  - The client pays **₹30,000 in total for year 1**: development ₹25,000 plus a platform package of ₹5,000.
  - The team pays Play Console + Firebase for 12 months.
  - Payments are 40 / 30 / 30 on day 1 / day 10 / day 20.
- **Timeline:** 20 working days, full scope. The Play closed test (12 testers × 14 days for a new personal account) must start by **day 6**.

## 4. Open items / risks (owner)
0. **One issue = one PR:** a PR must close exactly one open issue, and a second PR for the same issue fails CI. Oversized issues get split before work starts (#7 → #7/#84/#85/#86; #10 → #10/#92); Dependabot PRs are exempt.
1. **The Firebase projects don't exist yet (P3, #42). This is the main blocker.** Everything below waits on it; the full list is in the #42 comment:
   - `flutterfire configure` for customer_app (#92) and mechanic_app (#25);
   - **Identity Platform** must be on, or `assignDefaultRole` (#78) can't deploy and customers get no `role` claim; the admin `beforeSignIn` gate (#49) needs it too;
   - Cloud Tasks + Cloud Scheduler APIs for dispatch (#80).
2. **Nothing is deployed (P3, #41).** `deploy-firebase.yml` skips until the Workload Identity variables are set. Also restrict the **prod** WIF provider to `refs/tags/v*`: today anyone with write access can run the workflow with `target: prod`.
3. **The Play closed test must start by day 6 (P3, #43, #52):** 12 testers × 14 days, account in the client's name.
4. **Repo hygiene (P3, #40):**
   - CODEOWNERS lists `/firebase/` after `/firebase/functions/`, so Hem isn't code owner of his own Functions (last match wins).
   - Uncomment Dependabot pub/npm, since the folders exist now.
   - The root `.gitignore` rule `env/*.json` only covers the repo root; each app needs its own (customer_app has it, mechanic_app will need it).
5. **Merging:** the `main` ruleset wants a code-owner approval; the repo owner merges tested PRs with the admin bypass. Teammates can't bypass, so they need an approval from another owner.
6. **Security follow-ups:**
   - `LaneLog` redaction gaps (loosely typed maps, 3-decimal coordinates): on #48, fix before the Crashlytics sink goes live.
   - createBooking hardening (`vehicleId` / `offerId` with `/`, photo URLs from any bucket, rate limit vs PLAN): #38.
   - `secureCall` should reject `blocked` mechanics by default: #38.
7. **Product decisions pending:**
   - `in_progress` bookings can't be cancelled by anyone (#35).
   - Dispatch widens 3 → 5 → 10 km instantly, so `no_mechanic_found` can arrive in seconds (#16).
   - The offer's `areaName` needs a `pickup.locality` field in §8 (#29).
8. **Budget risk on OTP SMS (P3):** after the Play fee, about ₹2,900 is left for 12 months of Firebase. That's roughly 0–230 OTP SMS, depending on the Firebase bill (₹125–250 a month). Watch weekly; use the fair-use clause if growth passes launch scale.
9. **Client details:** name on the proposal cover, app name + logo (placeholder wordmark in `assets/brand/`), **application id** (customer_app uses the placeholder `com.roadside.customer`; settle it before #92), and personal vs organisation Play account.
10. **Translations:** `docs/glossary.md` and lane_ui's hi/gu strings are drafts and need a native review (P3).
11. **Recheck:** Ola Maps free tier and Firebase SMS price (as of Sep 2026). `phosphor_flutter` was skipped (last release May 2024, fails PLAN §3's 12-month rule); Lane uses the same Phosphor icons as SVGs via `flutter_svg`.

## 5. Local setup (Windows)
- **Flutter 3.47.5 / Dart 3.13.4** lives at `D:\brainstorm\flutter` (outside the repo). Add `D:\brainstorm\flutter\bin` to PATH.
- This machine's PATH is missing `C:\Windows\System32`, which Flutter's scripts need (`where.exe`, `powershell.exe`). Add it back, or prefix commands:
  ```powershell
  $env:Path = "D:\brainstorm\flutter\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0;" + $env:Path
  ```
- **No Android SDK yet** (`flutter doctor` shows ✗), so APKs are built by CI only. Install Android Studio + SDK 36 before testing on a phone.
- Java 17 is installed; the Firebase emulators want **Java 21**, so the emulator tests run in CI for now.
- Run things:
  ```bash
  cd packages/lane_ui/example && flutter run -d chrome        # every mode and type style in en/hi/gu
  cd packages/lane_ui/widgetbook && flutter run -d chrome     # component catalogue
  cd customer_app && flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
  cd packages/lane_ui && flutter test --update-goldens        # after an intended visual change
  ```

## 6. How to continue in a new Claude Code session
```bash
cd roadside-app
claude
```
Then say, for example:

> Read HANDOFF.md, PLAN.md and CLAUDE.md. I'm P1. Start issue #12 (U1 Home).

Useful commands:
- Your issues:
  ```bash
  gh issue list --assignee @me
  ```
- A milestone:
  ```bash
  gh issue list --milestone "Day 2 · Setup + wireframes signed off"
  ```
- Regenerate the wireframe PDF: open `wireframes/wireframes.html` in Chrome and print to A3 landscape, or use headless Chrome `--print-to-pdf`.
- Regenerate the Uber-style mockup maps (needs local Chrome):
  ```bash
  cd design/map-render
  npm i
  npm run render
  ```
  This uses OpenFreeMap vector tiles (free, keyless) + MapLibre.
- More ThreeUI backgrounds: see `design/threeui-capture/README.md`.

## 7. Earlier work in the same workspace (unrelated to this app)
- `D:\brainstorm\twenty-site`, the live "Twenty" design site: https://twenty-navy.vercel.app · repo https://github.com/CODER7657/twenty
- `~/.claude/skills/graphic-design-styles` (20-style skill), used to choose Lane's Swiss + Minimalism base.

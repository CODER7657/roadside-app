# P1 guide: customer app + Lane design system (repo owner, @CODER7657)

This guide goes from a fresh laptop to your final PR on day 20. Keep it open all sprint.

**You own:** `customer_app/`, `packages/lane_ui/`, `design/`. You are also the design lead: Hem (P2) and Ayush (P3) build their screens from your `lane_ui`, so **Lane lands first** (days 1–4).

---

## 1. Install the tools (day 1 morning, ~1.5 h)

Windows 11 (PowerShell as admin). On macOS use `brew` equivalents.

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Microsoft.OpenJDK.21 -e
winget install --id Google.AndroidStudio -e
winget install --id Microsoft.VisualStudioCode -e
```

Then:
1. **Flutter SDK (stable).**
   - In VS Code, install the *Flutter* and *Dart* extensions.
   - Open the command palette, run **Flutter: New Project**, and choose **Download SDK**. Pick a path without spaces, such as `C:\dev\flutter`.
   - Let it add Flutter to PATH.
2. **Android Studio.** Open it, install **SDK Platform 36 (Android 16)**, *Android SDK Command-line Tools* and *Build-Tools*, and create an emulator.
3. Run these in a new terminal:
   ```powershell
   flutter doctor --android-licenses
   flutter doctor
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   gh auth login
   winget install --id Gitleaks.Gitleaks -e
   ```
   `flutter doctor` must be all green (Android + Chrome). `gh auth login` should use HTTPS in the browser.
4. **Claude Code.** Install it:
   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```
   (or `npm i -g @anthropic-ai/claude-code`), then run `claude` once to sign in.
5. **Phone.** Turn on developer options and USB debugging. `flutter devices` must list it. Emulators fake GPS, so always test maps on the real phone. Borrow one cheap 3 GB RAM phone for performance checks.
6. **Figma** (free): create the team file "Lane" (6.14).

## 2. Accounts & access (day 1)
- Add Hem and Ayush as collaborators:
  ```bash
  gh api -X PUT repos/CODER7657/roadside-app/collaborators/<their-username> -f permission=push
  ```
  Or use Settings → Collaborators.
- Turn on 2FA on GitHub.
- Ayush adds you to the Firebase **dev** project. Run the app once with App Check debug, copy the debug token from logcat, and add it in *App Check → Apps → Manage debug tokens*. Never commit it.
- Ask Ayush for `env/dev.json` (map key) over a private channel. It's git-ignored.

## 3. Get the repo and first look
```bash
git clone https://github.com/CODER7657/roadside-app.git
cd roadside-app
code .
```
Read, in order:
1. `PLAN.md` §0–§7 (Lane is §6, the build recipe is §7)
2. `wireframes/Wireframes.pdf`, pages 1–4 (C and U frames)
3. `CLAUDE.md`, then this guide's §6
4. `assets/` (fonts, Phosphor pictograms, ThreeUI backgrounds, maps)

## 4. How to use Claude Code every day
Start it from the **repo root** so it reads `CLAUDE.md` plus `customer_app/CLAUDE.md` / `packages/lane_ui/CLAUDE.md`:
```bash
cd roadside-app
claude
```
Good prompt shape (one feature per session):
> Read PLAN.md §6, §7 and §10 U6 and look at wireframe U6 in wireframes/Wireframes.pdf. In customer_app, build the Confirm location screen using LaneMapScaffold, CenterPin, AccuracyBadge and LaneDock. Follow CLAUDE.md. Add ARB keys in en/hi/gu, a golden test, and handle permission-denied and GPS-off. Then run flutter analyze, flutter test and tool/lint_design.sh customer_app/lib.

Rules of thumb:
- Always review the diff (`git diff`) before committing. You own the code, not Claude.
- If Claude wants to edit another member's folder or `PLAN.md`, stop and open an issue instead.
- Use `/clear` between features so each session starts clean.

## 5. The daily loop (every issue)

**One issue = one branch = one PR.** Put exactly one `Closes #<issue>` in the PR; CI's **Linked issue** check fails otherwise, or if that issue already has a PR. Review fixes go to the same branch/PR. If an issue turns out too big, ask Ayush (P3) to split it before you start.

```bash
git switch main
git pull
git switch -c p1/<issue-number>-<short-name>           # or lane/<component> for lane_ui work
# … build with Claude Code …
cd customer_app
dart format .
flutter analyze
flutter test
cd ..
bash tool/lint_design.sh customer_app/lib
git add -A
git commit -m "feat: confirm location screen with accuracy badge"
git push -u origin HEAD
gh pr create --fill                     # add screenshots + "Closes #<issue>"
```
Then:
- CI must show a green **CI result**.
- Get 1 review from Hem or Ayush. `lane_ui` changes need both.
- Squash-merge and delete the branch.

Merge something every day.

## 6. Your 20 days (matches your GitHub issues)

| Days | What | Milestone |
|---|---|---|
| 1 | Create `packages/lane_ui`: tokens (from `design/lane_tokens.dart`), fonts, `LaneTheme`, `AmbientController`, `LaneApp`. Invite the team | Day 2 |
| 2 | **Wireframe sign-off with the client**; Figma Foundations | Day 2 |
| 3–4 | lane_ui v0.1: `LaneButton` (ThreeUI Launch / Spinning Border / Gradient CTA), hold/slide, fields, chips, badges, PlateChip, states; the 5 templates + `LaneDock`; Widgetbook + goldens. **Tag lane_ui 0.1 so Hem and Ayush can build** | Day 6 |
| 3–6 | `customer_app` scaffold (flavours, App Check, l10n), C1–C10, U1 + city chip + outside-area state, U2–U3, U4–U7 → `createBooking` | Day 6 |
| 7–9 | JourneyRail, TrustPass, OTP display, rolling number, pulse, countdown; U8–U11 | Day 10 |
| 10 | **Two-phone demo** with Hem's mechanic app | Day 10 |
| 11–14 | U12–U18, SOS + share trip + SMS fallback, ambient modes polish | Day 14 |
| 15–16 | Goldens per screen, TalkBack, 200% text, low-end phone 60 fps | Day 20 |
| 17–18 | Field test in Ahmedabad (you lead), Ankleshwar/Bharuch with Ayush | Day 20 |
| 19–20 | Release build, store graphics, final PRs, handover | Day 20 |

## 7. Things that are easy to get wrong
- **Beacon amber is never text on light backgrounds** (1.7:1). It's a fill with dark text.
- **Red only for SOS/danger.** Cancelled bookings are grey.
- Hindi/Gujarati: never set `height:` by hand; use `scriptMetrics`.
- Maps: the pin must stay above the dock. Test with the dock at half height.
- No `print()`. Use `LaneLog` from roadside_core.

## 8. Final PRs and release (days 19–20)
1. All your issues closed; `main` green.
2. Bump versions in `customer_app/pubspec.yaml` and open `chore: release v1.0.0`.
3. After merge, a repo admin (you, or Ayush if you gave him admin) tags `v1.0.0`:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   **Release Android** builds the signed, obfuscated AAB and **Deploy Firebase** ships to prod. Only admins can push `v*` tags, and that is the production gate.
4. Upload the store graphics with Ayush. Update `HANDOFF.md` with anything the client needs to know.

# HANDOFF: state of the project on 28 Sep 2026 (kickoff pack)

Read this first if you're picking the project up in a new session. The source of truth is [PLAN.md](PLAN.md); this file says **where things stand and why**.

## 1. What exists

| Thing | Where | Status |
|---|---|---|
| Plan rev 2 (Lane design, security, 20 days, 3 cities, ₹25k + ₹5k) | `PLAN.md` (also `D:\brainstorm\PLAN.md`; v1 kept as `D:\brainstorm\PLAN.v1.md`) | ✅ Done |
| Client proposal (9 pages, ₹30,000 all-in year 1) | `proposal/Proposal.pdf` (source `proposal.html`, images in `proposal/img/`) | ✅ Ready to send; fill the client's name on the cover |
| Wireframes (44 frames: C1–C10, U1–U18 + U1·SOS + U1·Area, M1–M9, A1–A6) | `wireframes/Wireframes.pdf`, `png/`, source `wireframes.html` | ✅ Needs client sign-off (issue for P1, Day 2) |
| Design tokens | `design/tokens.json`, `design/lane_tokens.dart` | ✅ Starter; P1 moves them into `packages/lane_ui` on day 1 |
| Assets | `assets/`: fonts (OFL), Phosphor icons (MIT), ThreeUI renders (MIT), brand marks, real OSM maps | ✅ |
| Repo process | CODEOWNERS, PR template, issue forms, CONTRIBUTING, SECURITY, `.gitattributes`, `.editorconfig`, design lint | ✅ CODEOWNERS still has `@HEM_GITHUB` / `@AYUSH_GITHUB` placeholders |
| CI/CD | `.github/workflows/`: CI (one required check **CI result**), PR hygiene, Deploy Firebase (keyless), Release Android | ✅ CI green on `main`; deploy/release skip until Firebase and signing are configured |
| Protection | Ruleset on `main` (PR, 1 approval, code owners, resolved threads, required checks **CI result**, **PR title**, **Linked issue**, squash only); **one issue = one PR** enforced by `pr-hygiene.yml`; tag ruleset (`v*` admins only); squash-only + auto-delete branches | ✅ Active |
| Backlog | 72 issues: #1–#3 "Start here" guides, then P1 = 23, P2 = 22, P3 = 27 (incl. the Start issues) across milestones Day 2 / 6 / 10 / 14 / 20 and **Launch · Live for users** (production access, staged rollout, monitoring, runbooks, supply onboarding, handover, 1-month support) | ✅ |
| Folder rules | `CLAUDE.md` in root, `customer_app/`, `mechanic_app/`, `admin_panel/`, `firebase/`, `firebase/functions/`, `packages/lane_ui/`, `packages/roadside_core/` | ✅ The folders hold only CLAUDE.md until day 1 |

## 2. Team

| | Who | Owns | Start issue |
|---|---|---|---|
| P1 | Repo owner (@CODER7657) | customer_app, lane_ui, design | #1 |
| P2 | Hem | mechanic_app, Cloud Functions | #2 |
| P3 | Ayush | admin_panel, roadside_core, Firebase, rules, CI, docs, store | #3 |

## 3. Decisions made (don't reopen them without the team)
- **Design system "Lane":** Swiss base, highway-signage legibility, Beacon amber `#FFB81C`, and signal colours with red reserved for danger. It has four ambient modes (Day / Night / Glare / Saver), the Journey Rail, the Trust Pass and the thumb dock.
- **ThreeUI is the visual source:**
  - Fonts: Onest, Instrument Serif and JetBrains Mono, plus Anek for Hindi/Gujarati.
  - Buttons: Launch → primary, Spinning Border → secondary, Gradient CTA → pill, Gradient Beam → SOS ring.
  - Backgrounds are pre-rendered stills; the apps never run WebGL.
- **Icons:** Phosphor duotone via `phosphor_flutter` (the earlier hand-drawn pictograms were replaced).
- **Maps:** Ola Maps in the apps. The mockups use real OSM tiles with a real OSRM route (2.47 km, Bodakdev → Thaltej).
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
0. **One issue = one PR:** a PR must close exactly one open issue, and a second PR for the same issue fails CI. Oversized issues get split (by P3) before work starts; Dependabot PRs are exempt.
1. **Budget risk on OTP SMS (P3):**
   - After the Play fee, about ₹2,900 is left for 12 months of Firebase, which covers roughly 200–250 OTP SMS at about ₹6 each.
   - Watch it weekly, and use the proposal's fair-use clause if growth passes launch scale.
2. **GitHub plan limits:** required reviewers on environments aren't available for private repos on this plan, so production is gated by the admin-only `v*` tag ruleset. If Ayush cuts releases, give him the admin role.
3. **CODEOWNERS placeholders (P3):** swap in real usernames after Hem and Ayush accept their invites. Until then their folders have no code owner.
4. **Collaborators (P1):** invite Hem and Ayush:
   ```bash
   gh api -X PUT repos/CODER7657/roadside-app/collaborators/<username> -f permission=push
   ```
5. **Dependabot (P3):** uncomment the pub/npm entries once the Flutter/Node folders exist.
6. **Client details:** name on the proposal cover, app name + logo (placeholder wordmark in `assets/brand/`), and personal vs organisation Play account.
7. **Translations:** `docs/glossary.md` is a draft and needs a native Hindi/Gujarati review (P3).
8. **Stale info to recheck on day 1:** Ola Maps free tier and Firebase SMS price (both as of Sep 2026), and the Play target API (36 since 31 Aug 2026).

## 5. How to continue in a new Claude Code session
```bash
cd roadside-app
claude
```
Then say, for example:

> Read HANDOFF.md, PLAN.md and CLAUDE.md. I'm P1. Start issue #4 (Lane foundations).

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
- Regenerate the mockup maps:
  ```bash
  python design/make_maps.py
  ```
  This uses OSM tiles: one-off, low volume, with attribution.
- More ThreeUI backgrounds: see `design/threeui-capture/README.md`.

## 6. Earlier work in the same workspace (unrelated to this app)
- `D:\brainstorm\twenty-site`, the live "Twenty" design site: https://twenty-navy.vercel.app · repo https://github.com/CODER7657/twenty
- `~/.claude/skills/graphic-design-styles` (20-style skill), used to choose Lane's Swiss + Minimalism base.

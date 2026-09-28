# [App Name]: On-Demand Roadside Mechanic App

An Uber-style app for booking the nearest verified mechanic when a car, bike, scooter or EV breaks down. It launches in **Ahmedabad, Ankleshwar and Bharuch**.

**Start with [PLAN.md](PLAN.md).** It is the single source of truth for scope, design (Lane), data model, security and the 20-day timeline.

## Team

| Member | Role | Owns |
|---|---|---|
| **P1: repo owner (@CODER7657)** | Customer app + Lane design system | `customer_app/`, `packages/lane_ui/`, `design/` |
| **P2: Hem** | Mechanic app + Cloud Functions | `mechanic_app/`, `firebase/functions/` |
| **P3: Ayush** | Admin panel, Firebase, security rules, shared models, CI, docs | `admin_panel/`, `packages/roadside_core/`, `firebase/*`, `.github/`, `docs/`, `tool/` |

Your work is in the GitHub issues labelled `P1`, `P2` or `P3`, grouped by milestone (Day 2, Day 6, Day 10, Day 14, Day 20).

## What's in this repo today

| Path | What it is |
|---|---|
| [PLAN.md](PLAN.md) | The full plan. Read §0 first |
| [CLAUDE.md](CLAUDE.md) | Rules every Claude Code session follows |
| [HANDOFF.md](HANDOFF.md) | Where things stand, decisions made, and what each member does first |
| [docs/onboarding/](docs/onboarding/) | **Personal guides, setup → final PR:** [P1](docs/onboarding/P1-customer-and-lane.md) · [P2 Hem](docs/onboarding/P2-mechanic-and-functions.md) · [P3 Ayush](docs/onboarding/P3-admin-firebase-security.md) |
| [CONTRIBUTING.md](CONTRIBUTING.md) · [SECURITY.md](SECURITY.md) | Branch → PR → review → squash-merge; how to report security issues |
| [.github/workflows/](.github/workflows/) | **CI** (path-filtered Flutter/Functions/rules checks, gitleaks, actionlint → one required "CI result"), **PR hygiene** (title + auto-labels), **Deploy Firebase** (dev on merge, prod on tag with approval, keyless), **Release Android** (signed, obfuscated AABs) |
| `*/CLAUDE.md` | Folder-level Claude Code rules for each owner's area |
| [wireframes/](wireframes/) | `Wireframes.pdf` (44 frames, every screen) + `png/` + the source `wireframes.html` |
| [proposal/](proposal/) | Client proposal `Proposal.pdf` (₹30,000 all-in year 1) + source |
| [design/tokens.json](design/tokens.json) | Lane design tokens (colours, type, space, motion, service areas) |
| [design/lane_tokens.dart](design/lane_tokens.dart) | Dart starter for `packages/lane_ui` tokens |
| [design/make_maps.py](design/make_maps.py) | Renders the real-map mockup backdrops (OSM) |
| [design/threeui-capture/](design/threeui-capture/) | How to render more ThreeUI backgrounds |
| [assets/fonts/](assets/fonts/) | Onest, Instrument Serif, JetBrains Mono, Anek Devanagari, Anek Gujarati (+ OFL licenses) |
| [assets/pictograms/](assets/pictograms/) | Phosphor icons: problems, vehicles, UI. `lane/` = tinted, `duotone/`, `regular/`, `preview.png` |
| [assets/threeui/](assets/threeui/) | Pre-rendered ThreeUI backgrounds (splash, onboarding, store graphics) + button reference renders |
| [assets/brand/](assets/brand/) | Symbol, app-icon preview, placeholder wordmark |
| [assets/maps/](assets/maps/) | Real Ahmedabad map backdrops for mockups (day/night, with a real route) |
| [tool/lint_design.sh](tool/lint_design.sh) | CI check that app code uses Lane (no raw colours, strings, magic numbers) |
| [docs/](docs/) | Licenses and the en/hi/gu glossary |

The Flutter apps, packages and Firebase folders are created on day 1 (see the issues).

## Quick start (day 1, everyone)

1. Install everything in PLAN.md §4 and run `flutter doctor` until it's green.
2. Accept the GitHub invite and turn on 2FA.
3. Read PLAN.md §0, §2, §5, §6, §7, then your own sections.
4. Open your **"Start here"** issue (it contains your personal guide), then your `Day 2` milestone issues.

## Licenses

Our code and designs are private to the project.

Third-party material and its licenses:
- ThreeUI Community (MIT): button styles, backgrounds, type pairing.
- Phosphor Icons (MIT).
- Fonts: SIL OFL 1.1.
- Map data: © OpenStreetMap contributors (ODbL).

Details are in [docs/licenses.md](docs/licenses.md).

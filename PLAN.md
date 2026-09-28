# PLAN.md — [App Name] On-Demand Roadside Mechanic App

> Single source of truth for the team. Every member (and every Claude Code session) reads this first.
> **Shared contract** = sections 5, 6, 7, 8, 9 and 12. Any change to them goes through a Pull Request that edits
> this file and gets approval from **both** other members.
>
> Revision 2: this version locks the design system ("Lane"), adds the security and privacy layer, and adds a
> step-by-step recipe so every member builds screens that look and behave the same.

---

## 0. How to use this document

| If you are… | Read first | Then |
|---|---|---|
| Starting on the project | 1, 2, 3, 4, 5 | Day-1 row in 16 |
| Building any screen | **6 (Lane design system)**, 7 (recipe) | Your app's screen list in 10 |
| Touching Firestore / Functions | 8, 9, 11 | 12 (security) |
| Reviewing a PR | 7.9 (Definition of Done), 14 | 12.14 (security checklist) |
| Running Claude Code | 15 (copy into `CLAUDE.md`) | the section for your task |

Words used in this plan: **must** = a CI check or reviewer will block the PR; **should** = strong default, explain in the PR if you deviate.

---

## 1. Product Summary

An Uber-style app where a person whose vehicle breaks down on the road can book the nearest verified mechanic, see the price upfront, track the mechanic live, and pay by UPI.

- **Launch cities (all on day 1):** **Ahmedabad, Ankleshwar and Bharuch**. Each is a *service area* (`serviceAreas/{cityId}`) that admins can switch on or off, so more cities can be added later without code changes.
- **Vehicles:** car, bike, scooter, EV
- **Platforms:** Android apps (customer + mechanic) and a web admin panel
- **Languages:** English, Hindi, Gujarati
- **Design system:** **Lane** (section 6). One shared Flutter package, `packages/lane_ui`, gives all three apps the same colours, type, components, motion and screen templates. Apps never define their own theme.

---

## 2. Team & Ownership (independent, with two shared packages)

| Person | Owns | Folder |
|---|---|---|
| **P1 — repo owner (@CODER7657)** | Customer app, **Lane design system** | `customer_app/`, `packages/lane_ui/`, `design/` |
| **P2 — Hem** | Mechanic app, Cloud Functions (dispatch, notifications, all status changes) | `mechanic_app/`, `firebase/functions/` |
| **P3 — Ayush** | Admin panel, Firebase setup, security rules, shared data models, CI, docs, Play Store listing | `admin_panel/`, `packages/roadside_core/`, `firebase/*.rules`, `firebase/*.json`, `.github/`, `docs/` |

**Rules**
- You only edit your own folders. Need something from another folder? Open an issue and tag the owner.
- The two shared packages (`lane_ui`, `roadside_core`) are used by everyone. `CODEOWNERS` makes any PR that touches them need approval from **both** other members, so a change can't silently break someone else's app.
- Need a new component or token? Open a `lane:request` issue with a screenshot or sketch. P1 adds it to `lane_ui` (usually within 1–2 days). Until then, build it inside your app under `lib/_local_ui/` and move it into `lane_ui` later. Never copy-paste `lane_ui` code into your app.

---

## 3. Tech Stack

| Area | Choice |
|---|---|
| Apps | Flutter (stable channel), Dart 3, **Android `targetSdk 36` (Android 16), `minSdk 24`** |
| Admin panel | Flutter Web on Firebase Hosting |
| Design system | `packages/lane_ui` (tokens as `ThemeExtension`, components, templates, motion, haptics) |
| Shared models | `packages/roadside_core` (Firestore models, enums, status machine, validators) |
| State management | Riverpod (`flutter_riverpod`, `riverpod_annotation` + `riverpod_generator`) |
| Navigation | `go_router` |
| Models | `freezed` + `json_serializable` (in `roadside_core` only) |
| Backend | Firebase: Auth, Firestore, Storage, Cloud Messaging, Cloud Functions (2nd gen), **App Check**, Crashlytics, Remote Config |
| Region | **`asia-south1` (Mumbai)** for Firestore, Storage and Functions. This can't be changed after the project is created. |
| Functions | TypeScript, Node.js LTS, `zod` for input validation |
| Login | Phone number + OTP (Firebase Auth, with an India-only SMS region policy) for customers and mechanics; Google sign-in plus an admin claim for the admin panel |
| Maps | Ola Maps (`ola_maps` Flutter plugin; free tier currently 100,000 events a month from 1 Sep 2026), fallback Google Maps. **Lock this on day 1 after re-checking current limits.** |
| Location | `geolocator` |
| Nearby search | GeoHash via `geoflutterfire_plus` (server side, in Functions) |
| Payments (Phase 1) | UPI deep link / QR paid straight to the mechanic; the customer taps "I have paid" and the mechanic confirms. The app never holds money. |
| Animation | Flutter implicit and explicit animations, the `animations` package (page transitions), `lottie` for 4 illustrations only |
| Icons | `material_symbols_icons` (Rounded, weight 500), plus a custom problem pictogram set (SVG via `flutter_svg`) |
| Fonts | From **ThreeUI**: **Onest** (Latin UI), **Instrument Serif** (brand headlines), **JetBrains Mono** (numbers, codes). Plus **Anek Devanagari / Anek Gujarati** for Hindi and Gujarati. All OFL, bundled in `lane_ui` (never fetched at runtime) |
| Visual source | **ThreeUI Community** (MIT, https://github.com/MengTo/threeui): button styles, pre-rendered 3D backgrounds, type pairing (section 6.17) |
| UI quality | `widgetbook` (component catalogue), `alchemist` (golden screenshot tests) |
| Testing | `flutter_test`, `mocktail`, `integration_test`, `@firebase/rules-unit-testing`, Firebase Emulator Suite |

**Common Flutter packages:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `cloud_functions`, `firebase_app_check`, `firebase_crashlytics`, `firebase_remote_config`, `flutter_local_notifications`, `geolocator`, `flutter_riverpod`, `go_router`, `image_picker`, `flutter_image_compress`, `cached_network_image`, `url_launcher`, `share_plus`, `connectivity_plus`, `battery_plus`, `permission_handler`, `lottie`, `animations`, `flutter_svg`, `intl`, `flutter_localizations`, `lane_ui` (path), `roadside_core` (path), and the map package for the chosen provider.

Add a new package only through a PR that explains why. Check that it's maintained (updated in the last 12 months) and that its license is MIT, BSD, Apache-2.0 or similar.

---

## 4. What to Install

### Everyone
1. **Git** — https://git-scm.com
2. **GitHub account** (added as a collaborator; turn on 2FA, which the repo requires)
3. **Flutter SDK** (stable) — https://flutter.dev
4. **Android Studio**: Android SDK (API 36), emulator, command-line tools
5. **VS Code** with extensions *Flutter*, *Dart*, *Error Lens*; optional *GitLens*
6. **Node.js LTS** — https://nodejs.org
7. **Firebase CLI:** `npm install -g firebase-tools`, then `firebase login`
8. **FlutterFire CLI:** `dart pub global activate flutterfire_cli`
9. **Java JDK 21** (for the Firebase Emulator Suite)
10. **Claude Code**
11. **gitleaks** (secret scanner; also runs in CI): https://github.com/gitleaks/gitleaks
12. Run `flutter doctor` until everything is green (`flutter doctor --android-licenses`)
13. Figma (free) account, with view access to the team file (6.14)

### Extra per person
- **P1:** a real Android phone with developer mode and USB debugging (emulators fake GPS). Ideally one cheap, low-RAM phone for performance checks.
- **P2:** a real Android phone (a second phone helps you test customer and mechanic together)
- **P3:** Chrome (Flutter Web), **Claude Cowork** (docs, sheets, reports), a password manager shared with the client for keys (never in the repo)

---

## 5. Repository Structure (one private GitHub repo)

```
roadside-app/
├── PLAN.md                     # this file (shared contract)
├── CLAUDE.md                   # rules for Claude Code (copy of section 15)
├── .github/
│   ├── CODEOWNERS              # P3
│   ├── pull_request_template.md
│   ├── dependabot.yml
│   └── workflows/              # CI (section 14)
├── packages/
│   ├── lane_ui/                # P1: design system (section 6)
│   │   ├── lib/src/tokens/     # colours, type, space, radius, motion, haptics
│   │   ├── lib/src/theme/      # LaneTheme, ambient modes
│   │   ├── lib/src/components/ # LaneButton, JourneyRail, TrustPass, ...
│   │   ├── lib/src/templates/  # LaneMapScaffold, LaneFlowScaffold, ...
│   │   ├── lib/l10n/           # strings used inside components (en/hi/gu)
│   │   ├── assets/fonts/       # Anek + JetBrains Mono (OFL)
│   │   ├── assets/pictograms/  # problem + vehicle SVGs
│   │   ├── widgetbook/         # component catalogue app
│   │   └── test/goldens/
│   └── roadside_core/          # P3: models, enums, status machine, validators
├── customer_app/               # P1
├── mechanic_app/               # P2
├── admin_panel/                # P3
├── firebase/
│   ├── functions/              # P2
│   ├── firestore.rules         # P3
│   ├── storage.rules           # P3
│   ├── firestore.indexes.json  # P3
│   ├── rules_tests/            # P3 (emulator tests for the rules)
│   └── firebase.json           # P3 (+ hosting headers for admin & share page)
├── design/                     # P1: token source, Figma export notes, screen specs
├── tool/                       # P3: lint_design.sh, check_strings.dart, scripts
└── docs/                       # P3: privacy policy, test checklist, store listing, runbooks
```

### Inside each app (feature-first, the same in all three)
```
lib/
├── main_dev.dart / main_prod.dart   # flavour entry points
├── app/          # app.dart (LaneApp), router.dart, providers.dart
├── features/
│   └── <feature>/   # e.g. confirm_location
│       ├── data/          # repositories (Firestore, Functions calls)
│       ├── application/   # Riverpod providers / notifiers
│       └── presentation/  # screens + feature-only widgets
├── l10n/         # app_en.arb, app_hi.arb, app_gu.arb
└── _local_ui/    # temporary widgets waiting to move into lane_ui
```

**Environments:** two Firebase projects: `roadside-dev` (everyone, plus emulators) and `roadside-prod` (client-owned; only P3 deploys). Each app has `dev` and `prod` flavours (`flutterfire configure` once per flavour). You never test against prod data.

---

## 6. Lane — the design system

### 6.1 The idea in one line

> **Calm in a crisis, readable at a glance.** Lane borrows from highway signage, which is designed to be read at 80 km/h by a stressed driver, and from the lane line, the one mark that keeps you on course.

Our user isn't browsing. They're standing next to a dead vehicle, maybe at night, maybe in harsh sunlight, maybe with 9% battery and one bar of network, often holding the phone in one hand. The mechanic is outdoors with greasy hands, glancing at a phone in a mount. Most apps in this category look like generic food-delivery clones. Lane is designed for **stress, glare, gloves and bad networks**, and that's what makes it different.

### 6.2 Who we design for

| Situation | What it means for the UI |
|---|---|
| Stressed, anxious | Slow calm motion, short sentences, always show "what happens next" |
| Night, dark highway | True-dark Night mode switches on at sunset (not only via the system setting) |
| Harsh midday sun | **Glare mode**: pure black on white, heavier weights, bigger text |
| Low battery | **Saver mode**: OLED-dark, motion off, fewer location fixes |
| One hand, walking | Every primary action is in the bottom 40% of the screen (the "thumb zone") |
| Gloves / greasy hands (mechanic) | 64 dp targets for critical actions, slide gestures instead of small taps |
| Patchy network | Honest offline strip, an SMS fallback, nothing that spins forever |
| Hindi / Gujarati readers, new smartphone users | One harmonised type family for all 3 scripts; icons plus words, never icons alone |
| Cheap Android phones | Flat surfaces (no blur), few shadows, 60 fps on a 3 GB RAM phone |

### 6.3 Five principles (use them to settle design arguments)

1. **Calm over clever.** Nothing on a stress screen bounces, flashes or shakes. Delight is kept for success moments.
2. **Signage-grade legibility.** Body text is bigger than the Material default (17 sp); body text contrast is ≥ 4.5:1 in every mode, and key numbers are ≥ 7:1.
3. **One job per screen.** Each screen has one primary button. If you need two, it's two screens.
4. **Thumb first.** The map or content sits on top and actions sit in the bottom **dock**. Nothing important lives in the top app bar.
5. **Never a dead end.** Every error, empty and offline state names the next action ("Send location by SMS", "Try 5 km radius", "Call support").

### 6.4 Style DNA

Lane is built from our graphic-design-styles reference (the 20-style skill):
- **Base: Swiss design.** A visible grid, flush-left type, strong size hierarchy, flat colour, and meaning carried by position and weight rather than decoration.
- **Plus one move from Minimalism.** One accent colour (Beacon amber) and generous empty space around the primary action.
- **Plus road signage.** Wide letter-spacing on small caps labels, a number-plate style for registration numbers, and pictograms with labels.

**Avoided on purpose** (write this in PR reviews if someone adds it):
- Glassmorphism or blur over the map (hurts legibility in sunlight and costs GPU on cheap phones).
- Gradients as backgrounds.
- Neumorphic shadows (fail contrast).
- Red for anything except SOS, danger or destructive actions.
- Springy overshoot animations on searching, tracking, payment or SOS screens.
- Emoji in UI copy.

### 6.5 Signature ideas

These are the things that make [App Name] look and feel like no other app in the category. Each one is a `lane_ui` component, so every app gets it for free.

**① Journey Rail: the status bar as a lane line.** The booking status (section 9) is drawn as a road lane: dashed segments between stops, each stop with its signal colour and icon. When the status advances, the dashes **flow** forward into the next stop (a 450 ms dash-offset animation), with a medium haptic tick. The same rail appears in:
- the customer tracking screen (horizontal, top of the dock)
- the mechanic job screen (horizontal)
- the booking detail and admin booking view (vertical, with timestamps)
- the Android notification (Android 16 **Live Updates**, `Notification.ProgressStyle`, whose "segments + points" model maps 1:1 to our stops; older Android versions get a standard ongoing notification with the same text)

The customer never has to wonder "what's happening now?"

**② Signal colours: status = colour, everywhere.** Each status owns one semantic colour (6.7), used for the rail stop, badges, the map route and the notification accent. **Red is reserved** for SOS, danger and destructive actions, so when users see red it always means danger. Cancelled or failed states are neutral grey, not red, which avoids panic.

**③ Ambient modes: the UI adapts to the road, not just the system setting.** `lane_ui` ships an `AmbientController` (a Riverpod provider) that picks one of four modes:

| Mode | When | What changes |
|---|---|---|
| **Day** | Default, between local sunrise and sunset | Warm "Chalk" background (less glare than pure white) |
| **Night** | After local sunset (computed on the phone from lat/lng, with no network) or when system dark mode is on | "Asphalt" dark palette, dimmer map style, lighter signal tints |
| **Glare** | User taps the ☀ button in the dock, or (optional) the light sensor reads > 10,000 lux for 5 s | Pure `#000` on `#FFF` (21:1), weights +100, body 19 sp, 2 px borders, no tinted surfaces |
| **Saver** | Battery ≤ 15 % or system battery saver on (`battery_plus`) | Night palette (OLED saves power), all non-essential motion off, Lottie becomes a static frame, 3D map off |

Priority: **user's manual choice > Saver > Glare > Night > Day.** Switching modes cross-fades over 280 ms and never rebuilds the map.

**④ The Dock: one-thumb layout.** Every map screen uses `LaneMapScaffold`: the map fills the screen and a **dock** (a bottom sheet with 3 snap heights: peek, half, full) holds everything else. The primary button always sits at the same spot: 16 dp above the bottom safe area, full width, 64 dp tall. Customers' muscle memory learns "the big button at the bottom moves me forward".

**⑤ Deliberate gestures for high-stakes actions.** These prevent pocket taps and panic taps without adding dialogs.
- **Hold to SOS** (`LaneHoldButton`): hold for 1.5 s. A red ring fills while you hold; there's a heavy haptic at arm and success haptics at fire. Letting go early cancels with no side effects.
- **Slide to accept** (`LaneSlideToConfirm`, mechanic offers): works with gloves. The 30 s `CountdownRing` wraps the slider.
- **Destructive actions** (cancel booking, delete account): a confirm sheet with a required reason chip, never a single tap.

**⑥ Calm motion.**
- The searching screen shows a soft ring pulse on a **10-second breathing cycle** (5 s expand, 5 s contract, about 6 breaths a minute) with the caption "We're finding the nearest mechanic". It gives the eye something slow and steady to follow instead of a frantic spinner. (It's a calming design choice; make no medical claims in copy.)
- The mechanic marker on the map glides between GPS fixes (linear interpolation over the 5 s update window, heading rotated smoothly) instead of teleporting.
- Numbers such as the ETA and price roll digit by digit when they change (`LaneRollingNumber`) instead of jumping.

**⑦ Arm's-length numerals.** The start code (OTP), the ETA and the amount are the three numbers that matter. They use JetBrains Mono (tabular, unambiguous 0/O and 1/l):
- The **OTP is shown at 56 sp, digits spaced 16 dp apart**, readable by a mechanic standing a metre away.
- Tapping the OTP makes it full screen at maximum brightness (`LaneOtpDisplay.fullscreen`).

**⑧ Trust Pass: the mechanic card as an ID.** When a mechanic accepts, the customer sees a `TrustPass`, laid out like an access card:
- the mechanic's photo, name, verified badge (only for `approved` + KYC-checked mechanics), and rating with job count
- shop name and the vehicle types they handle
- the start code, with the line "Share this code only when the mechanic is standing with you"

It reassures the customer and prevents fake-mechanic fraud at the same time.

**⑨ Plate Chip.** Registration numbers are shown in `PlateChip`: white, a 1.5 px black border, a small "IND" band and mono letters, like an Indian number plate. Customers recognise their vehicle instantly, and mechanics can match the plate at the roadside.

**⑩ Honest offline.**
- A thin `OfflineStrip` slides under the status bar when connectivity drops. It's neutral grey, not red, and says what still works.
- Any action that needs the network is disabled with a reason, and "Get Help" switches to **"Send location by SMS"**, which opens the SMS app pre-filled with coordinates and a map link.

**⑪ One voice in three scripts.**
- English uses **Onest**, the clean geometric sans from ThreeUI.
- Hindi and Gujarati use **Anek Devanagari / Anek Gujarati** (by Ek Type, Mumbai), sized and weighted in `lane_ui` to match Onest's x-height and stroke. Switching language changes the words, not the personality of the app.
- Line heights are set per script (6.8) so matras never clip.

**⑫ Haptic vocabulary.** The same event always feels the same (6.11). A mechanic with the phone in a mount can *feel* a new offer or a status change.

### 6.6 Brand assets
- **Logo:** a wordmark in Instrument Serif ("[App Name]" with the italic in Beacon), plus a symbol that's a lane dash turning into a location pin. A starter logo is in `assets/brand/`; P1 finalises it by day 2. Export the launcher icon as an Android adaptive icon (foreground on Beacon).
- **Illustrations:** only 4 Lottie files (searching, job done, empty, no network), each ≤ 60 KB, flat 2-colour (Asphalt + Beacon), stored in `lane_ui/assets`. Check each file's license before adding it and record it in `docs/licenses.md`.

### 6.7 Colour tokens

Contrast ratios below were calculated with the WCAG 2 formula. The CI golden tests re-check them (`test/contrast_test.dart`).

**Neutrals**

| Token | Day | Night | Use |
|---|---|---|---|
| `bg` | `#F4F3EE` Chalk | `#0E1014` Asphalt | Screen background |
| `surface` | `#FFFFFF` | `#181B21` | Cards, dock |
| `surfaceSunken` | `#EAE8E1` | `#0A0B0E` | Inputs, wells |
| `line` | `#D9D6CC` | `#2A2F38` | Dividers, 1 px borders |
| `ink` | `#14161B` (16.3:1 on bg) | `#EEF0F3` (16.7:1) | Primary text |
| `inkMuted` | `#4A5160` (7.2:1) | `#A9B0BD` (8.7:1) | Secondary text |
| `inkSubtle` | `#5F6676` (5.2:1) | `#8A92A0` (5.5:1 on surface) | Captions, hints (never for important info) |

**Brand**

| Token | Value | Use |
|---|---|---|
| `beacon` | `#FFB81C` | Primary action fill (the Get Help button, primary buttons), the logo, the active tab indicator |
| `onBeacon` | `#14161B` | Text/icons on Beacon (10.5:1) |

⚠ **Beacon is never text or an icon on a light background** (1.7:1 on white). It's always a fill with `onBeacon` on top. On Night backgrounds it may be used as text (11:1).

**Signal colours** (status and meaning)

| Token | Day (text / fill) | Night | Meaning | Statuses |
|---|---|---|---|---|
| `signal.wait` | `#9A5B00` (4.9:1) | `#FFC247` | Waiting / searching | `requested` |
| `signal.route` | `#1E5BFF` (4.7:1) | `#7EA2FF` | On the way, information, map route | `accepted`, `arriving` |
| `signal.go` | `#0B7A43` (4.9:1) | `#4BD28A` | Arrived, success, paid | `arrived`, `completed` |
| `signal.work` | `#5B3DF5` (5.5:1) | `#A594FF` | Job in progress | `in_progress` |
| `signal.stop` | `#C4262C` (5.2:1) | `#FF6B6E` | **SOS / danger / destructive only** | — |
| `signal.neutral` | `inkMuted` | `inkMuted` | Ended without success | `cancelled`, `no_mechanic_found` |

- White text on any Day signal fill is ≥ 4.9:1.
- On Night signal fills, use `ink` Day (`#14161B`, ≥ 6.5:1).
- Each signal also has a `…Tint` (the colour at 12% on `surface`) for badge backgrounds.

**Glare mode** overrides everything with: `bg #FFFFFF`, `ink #000000`, `line #000000`, and signal colours as the Day values at weight +100. Tints are replaced by 2 px outlines.

**Map:** use the provider's muted light or dark vector style (never the colourful default) so our route (`signal.route`, 6 dp) and markers stand out. Markers:
- the customer pickup is an `ink` pin with a Beacon dot
- the mechanic is a direction arrow in `signal.route` inside a white ring
- the accuracy halo is `signal.route` at 10%

### 6.8 Typography

Families (bundled, SIL OFL 1.1). The pairing is taken from ThreeUI:
- **Onest** (variable 100–900): all Latin UI text.
- **Anek Devanagari / Anek Gujarati** (variable): Hindi and Gujarati UI text. `lane_ui` picks the family from the active locale and applies `scriptMetrics` so it optically matches Onest.
- **Instrument Serif** (regular + italic): brand headlines only. Used for the splash, onboarding titles, empty-state titles, the admin dashboard hero numbers and store graphics. Its italic in Beacon is the signature (e.g. "Help on the road, *in minutes*"). It's Latin only, so in hi/gu those titles fall back to Anek 600.
- **JetBrains Mono**: OTP, amounts, ETA, registration numbers, booking IDs, `caps` labels.

The table below gives sizes for Onest; `display` numbers use JetBrains Mono, and `hero` uses Instrument Serif.

Numbers stay in Western digits in all three languages (standard in Indian apps). Money uses Indian grouping: `NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)`, which gives ₹1,25,000.

| Style | Size / line height (Latin) | Weight | Use |
|---|---|---|---|
| `hero` | 40 / 42, Instrument Serif (italic accent in Beacon) | 400 | Splash, onboarding, empty-state titles (Latin only) |
| `display` | 48 / 52 (mono for numbers) | 700 | ETA, OTP (the OTP uses 56), amount |
| `headline` | 30 / 36 | 700, width 105 | Screen titles on flow steps |
| `title` | 22 / 28 | 600 | Card titles, dock headers |
| `bodyLarge` | 19 / 26 | 500 | Glare mode body, key sentences |
| `body` | **17 / 24** | 450 | Default body text |
| `label` | 15 / 20 | 600 | Buttons, chips, tabs |
| `caps` | 12 / 16, letter-spacing +8% | 700 | Signage labels ("PICKUP", "START CODE") |
| `caption` | 13 / 18 | 450 | Helper text (the minimum size; never smaller) |

- **Devanagari and Gujarati:** line height × 1.18 and size +1 sp (the `scriptMetrics` in `lane_ui` do this automatically). Never set `height:` by hand.
- Support system text scaling up to **200%**. Layouts must reflow, not clip, and golden tests run at 1.0, 1.3 and 2.0.
- Truncation: titles may ellipsise after 2 lines. Addresses, prices, OTP and ETA **never** truncate.

### 6.9 Space, grid, shape, elevation

- **Spacing** (4 pt base): `s4 s8 s12 s16 s20 s24 s32 s48 s64`. Use nothing else.
- **Grid:**
  - Phone: 4 columns, 16 dp margins, 12 dp gutters.
  - Admin: 12 columns, 24 dp margins, 20 dp gutters, max content width 1440.
  - Content aligns to the left edge (Swiss flush-left). Centred text only on empty states and the OTP.
- **Radius:** `r6` (chips, plate) · `r12` (inputs, buttons) · `r16` (cards) · `r24` (dock, sheets top corners) · `pill` (badges, toggles). Modest on purpose: signage, not bubbles.
- **Elevation:** flat. Hierarchy comes from `surface` vs `bg` and 1 px `line` borders. Only two things cast a shadow: the dock and floating map buttons (`shadow.float`: y 4, blur 16, black 12%/40%).
- **Touch targets:** minimum 48 dp · primary buttons 56 dp · critical (Get Help, Accept, SOS, Pay) **64 dp**. At least 8 dp between tappable things.

### 6.10 Motion tokens

| Token | Value | Use |
|---|---|---|
| `instant` | 100 ms | Press states, toggles |
| `quick` | 180 ms | Chips, small reveals |
| `standard` | 280 ms | Dock snaps, page transitions, mode cross-fade |
| `calm` | 450 ms | Journey Rail flow, success check |
| `breath` | 10 s | Searching pulse cycle |
| `enter` curve | `Easing.emphasizedDecelerate` | Things arriving |
| `exit` curve | `Easing.emphasizedAccelerate` | Things leaving |
| `move` curve | `Curves.easeInOutCubic` | Things moving on screen |

- **Page transitions:**
  - Flow steps: `SharedAxisTransition` (horizontal).
  - Tabs: `FadeThroughTransition`.
  - Opening a detail from a card: container transform. All three come from the `animations` package, wired into `go_router` by `lane_ui`.
- **Overshoot / spring** is allowed only on success moments: the job-done check, the rating stars, and the "Paid" stamp.
- **Reduce motion:** when `MediaQuery.disableAnimations` is on (or Saver mode), every Lane animation becomes a 100 ms fade. You get this for free by using Lane components; custom animations must read `context.lane.motion.enabled`.
- **Performance budget:** 60 fps on the low-end test phone. Animate only transforms and opacity, never layout. Use `RepaintBoundary` around the map dock and the rail.

### 6.11 Haptics & sound (`LaneHaptics`)

| Event | Haptic |
|---|---|
| Select chip / tile | `selectionClick` |
| Primary button press | `lightImpact` |
| Status advances (rail flows) | `mediumImpact` |
| SOS armed (hold complete) / new offer (mechanic) | `heavyImpact` × 2, 120 ms apart |
| Error | `vibrate` once |

- **Mechanic offers:** a dedicated notification channel `offers` with a distinct sound, high importance and full-screen intent allowed while the job screen is active. Respect Do Not Disturb.
- The customer app plays no sounds except the arrival chime (can be turned off in settings).

### 6.12 Components (all in `lane_ui`; the Widgetbook shows every state)

| Component | What it is | Used in |
|---|---|---|
| `LaneButton.primary` | ThreeUI **Launch Button**: amber vertical gradient `#FDE68A → #FCD34D → #F59E0B`, text `#451A03`, 1 px `#FBBF24` ring, a 4 dp `#B45309` bottom ledge, and a soft amber glow. On press it moves down 2 dp and the ledge shrinks (a physical, glove-friendly click). 56/64 dp | Get Help, Confirm, Pay, every flow's main action |
| `LaneButton.secondary` | ThreeUI **Spinning Border Button**, static: a zinc gradient pill `#27272A → #09090B` with a 1 px highlight edge and uppercase mono label. The border beam spins only while loading | Call, Chat, secondary actions |
| `LaneButton.pill` | ThreeUI **Gradient CTA**: horizontal `#FFEBB1 → #FFC438` pill with inner highlights. Onboarding and marketing only | Onboarding, empty states |
| `LaneButton.ghost / danger` | Text button / `signal.stop` fill. Danger never uses the amber gradient | Cancel, delete |
| `LaneHoldButton` | Hold to confirm (SOS). Its ring is the ThreeUI **Gradient Beam** border (a conic beam in `signal.stop`) that fills while held | Customer: SOS |
| `LaneSlideToConfirm` | Slide to accept or finish | Mechanic: offer, complete job |
| `JourneyRail` | Lane-line status rail (horizontal/vertical) | Tracking, job, booking detail, admin |
| `SignalBadge` | Status pill (colour + icon + label) | Lists, cards |
| `TrustPass` | Mechanic ID card with start code | Customer: assigned, tracking |
| `PlateChip` | Registration number plate | Vehicles, offers, job, admin |
| `LaneOtpDisplay` / `LaneOtpInput` | 56 sp mono code / 4 big boxes with paste support | Customer tracking / mechanic start job, login |
| `LaneRollingNumber` | Digit-roll for ETA, price, earnings | Tracking, dashboard |
| `CountdownRing` | 30 s ring around a child | Mechanic offer |
| `BreathingPulse` | 10 s calm pulse | Searching |
| `ProblemTile` | Pictogram + label tile, 2-column grid | Problem picker |
| `VehicleTile` | Vehicle type pictogram + plate | Vehicles |
| `CenterPin` + `AccuracyBadge` | Fixed map pin with a lift animation while dragging; "±12 m" badge (green ≤ 20 m, amber ≤ 50 m, else grey + "Adjust pin") | Confirm location |
| `PriceRange` | "₹350–₹600" with a note on what's included | Estimate, offer |
| `OfflineStrip` | Connectivity banner | All screens (in `LaneApp`) |
| `LaneDock` | Bottom sheet with snap points and a primary slot | Map screens |
| `LaneSheet` / `LaneConfirmSheet` | Modal sheet; confirm sheet with a required reason | Cancel, delete |
| `LaneToast` | Bottom toast above the dock, auto-dismiss 4 s | Feedback |
| `EmptyState` / `ErrorState` | Illustration + one line + **a required action button** | Lists, failures |
| `SkeletonBlock` | Shimmer-free skeleton (static tone, calmer than shimmer) | Loading |
| `StarRating` | 48 dp stars with a spring on select | Rate & review |
| `ChatBubble` / `ChatComposer` | Chat parts; image messages | Chat |
| `LaneListTile`, `LaneTextField`, `LaneSwitch`, `LaneChip`, `LaneAvatar` | Basics | Everywhere |
| `StatCard`, `LaneDataTable`, `ConsoleShell` | Admin parts | Admin |

**Loading rule:** a skeleton when loading < 3 s is expected; a spinner only inside buttons. Anything that can take > 10 s shows what's happening in words.

### 6.13 Screen templates (every screen uses exactly one)

| Template | Layout | Screens |
|---|---|---|
| `LaneMapScaffold` | Full map, floating buttons (recenter, ☀ Glare, SOS) top right, `LaneDock` bottom | Home, confirm location, tracking, mechanic navigate |
| `LaneFlowScaffold` | Step header ("2 of 4" + progress lane), scrollable content, sticky bottom primary button | Add vehicle, problem, photos, registration, payment |
| `LaneStatusScaffold` | Large centred status visual (pulse / check / illustration), 1–2 lines, action at bottom | Searching, no mechanic, approval pending, job done |
| `LaneListScaffold` | Large title, filter chips, list, empty state | History, notifications, vehicles, earnings |
| `LaneFormScaffold` | Title, fields, sticky save | Profile, emergency contacts, settings |
| `ConsoleShell` (admin) | Left rail nav, top filter bar, 12-col content, Night palette by default ("control room") | All admin screens |

Key screen sketches (proportions, not pixels):

```
Customer · Home (LaneMapScaffold)      Customer · Tracking                 Mechanic · Incoming offer
┌──────────────────────────┐           ┌──────────────────────────┐        ┌──────────────────────────┐
│ ● Offline strip (if any) │           │        map + route       │        │  NEW REQUEST       0:24 ◔│
│                     [☀]  │           │  ◉ mechanic gliding      │        │  🛞 Flat tyre · Car       │
│        map               │           │                    [SOS] │        │  [GJ 01 AB 1234] plate   │
│          ⬤ you           │           ├──────────────────────────┤        │  2.4 km · Navrangpura    │
│                   [SOS]  │           │ ●━━●━━◐- - ○- - ○  rail   │        │  ₹350–₹600               │
├──────────────────────────┤           │ ARRIVING IN   7 min      │        │                          │
│ PICKUP                   │           │ ┌ TrustPass ───────────┐ │        │                          │
│ Near SG Highway, Thaltej │           │ │ photo Ramesh ✓ ★4.8  │ │        │                          │
│ [🚗 Swift · GJ01AB1234 ▾] │           │ │ START CODE  4 8 2 7  │ │        │ ┌──────────────────────┐ │
│ ┌──────────────────────┐ │           │ └──────────────────────┘ │        │ │ ≫  Slide to accept   │ │
│ │     GET HELP  →      │ │  64 dp    │ [ Call ]      [ Chat ]   │        │ └──────────────────────┘ │
│ └──────────────────────┘ │           └──────────────────────────┘        │        Decline           │
└──────────────────────────┘                                              └──────────────────────────┘
```

(Emoji above are placeholders for Lane pictograms; no emoji in the real UI.)

### 6.14 Figma ⇄ code (one source of truth)

- **Code is the source of truth.** Token values live in `packages/lane_ui/lib/src/tokens/*.dart` and are mirrored in `design/tokens.json`.
- The Figma file "Lane" has 4 pages: **Foundations** (Figma variables with the same names as the tokens, e.g. `signal/route`, `space/s16`), **Components** (matching `lane_ui` names 1:1), **Templates**, **Screens** (one frame per screen in section 10, in Day + Night + Hindi).
- To change a token: a PR edits the Dart + `tokens.json`, then P1 updates the Figma variables within 1 day. Nobody detaches Figma components.
- Designs are done at 360 × 800 (the most common Indian Android size), then checked at 320 wide and at 200% text size.

### 6.15 Copy & voice

- **Calm, short, specific, action-first.** Say what's happening and what's next.
  - ✗ "Searching…" → ✓ "Finding the nearest mechanic. We'll notify you when someone accepts."
  - ✗ "Error 500" → ✓ "Couldn't send your request. Check your internet or send your location by SMS."
  - ✗ "Are you sure?" → ✓ "Cancel this booking? The mechanic is 3 min away."
- Use "you" and "we". No jargon ("geohash", "sync"), no ALL CAPS sentences (only `caps` labels), no exclamation marks on problem screens.
- Every string is an ARB key: `screen_element_purpose` (e.g. `tracking_eta_label`). Hindi and Gujarati are translated by a native speaker, not machine-only. P3 keeps a glossary in `docs/glossary.md` so "mechanic", "start code", "pickup" are translated the same way everywhere.

### 6.16 Accessibility (must)
- Body text contrast ≥ 4.5:1, large text and icons ≥ 3:1, OTP / ETA / price ≥ 7:1 (the tokens above already meet this).
- Never colour alone: every signal also has an icon and a word.
- Every icon-only button has a `Semantics` label (localised). The Journey Rail announces "Step 3 of 6, mechanic on the way".
- Text scaling to 200% without clipping; test with TalkBack once per sprint.
- Focus order follows visual order; the dock's primary button is reachable in ≤ 3 swipes with TalkBack.

### 6.17 ThreeUI: what we take and how

**What ThreeUI is.** [ThreeUI Community](https://github.com/MengTo/threeui) by Meng To is MIT-licensed. The team has chosen it as the visual source for type, buttons and backgrounds.

**How it reaches Flutter.** ThreeUI is written for the web (React / WebGL), so we don't run it inside the Flutter apps. We take three things:

| From ThreeUI | In our apps | Where the files are |
|---|---|---|
| Type pairing: Instrument Serif + Onest + JetBrains Mono | 6.8 | `assets/fonts/` (+ OFL texts) |
| Buttons: Launch Button, Spinning Border, Gradient CTA, Gradient Beam | Re-implemented in Dart as `LaneButton.*` / `LaneHoldButton` (6.12), with the exact colours and shadows listed there | Reference renders in `assets/threeui/buttons/` |
| Backgrounds: Emerald Horizon (re-hued to amber), Stream Convergence (re-hued to signal red/amber/green), Warp Field, Liquid Form | **Pre-rendered still images** (JPG/WebP), never live WebGL. Used behind the splash, onboarding, login, the approval-pending screen, the admin login and the Play Store graphics | `assets/threeui/backgrounds/` |

**Rules**
- Backgrounds only go on screens with no map and little text. Always put a dark scrim (≥ 60% `bg`) under text and keep contrast ≥ 4.5:1.
- The Night palette is the base for these screens.
- Keep the MIT notice in `docs/licenses.md` and the app's "Open-source licenses" screen (Flutter's `showLicensePage` + a custom entry for ThreeUI).
- To render a new background:
  1. Run ThreeUI locally (`npm install && npx vite`).
  2. Use `design/threeui-capture/` (the capture page + instructions).
  3. Export at 1080×2400 (phone) or 1024×500 (Play feature graphic).

---

## 7. How to build a screen (the recipe every member follows)

### 7.1 Set up the app once
```dart
// lib/app/app.dart
class RoadsideApp extends ConsumerWidget {
  const RoadsideApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LaneApp.router(                 // from lane_ui: theme, ambient modes, OfflineStrip,
      routerConfig: ref.watch(routerProvider), // page transitions, text-scale clamp, l10n delegates
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

### 7.2 Pick the template, then fill the slots
```dart
class ConfirmLocationScreen extends ConsumerWidget {
  const ConfirmLocationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;                       // tokens: lane.color / .space / .text / .motion
    final l10n = AppLocalizations.of(context);
    final pin = ref.watch(pickupPinProvider);        // your feature's Riverpod state

    return LaneMapScaffold(
      map: const PickupMap(),                        // feature widget
      overlay: CenterPin(lifted: pin.isDragging),
      dock: LaneDock(
        header: AccuracyBadge(meters: pin.accuracyMeters),
        children: [
          Text(l10n.confirmLocation_title, style: lane.text.title),
          Gap(lane.space.s8),
          Text(pin.address ?? l10n.confirmLocation_findingAddress, style: lane.text.body),
          Gap(lane.space.s16),
          LaneTextField(label: l10n.confirmLocation_landmarkLabel, onChanged: ...),
        ],
        primary: LaneButton.primary(
          label: l10n.confirmLocation_cta,
          onPressed: pin.canConfirm ? () => ref.read(bookingDraftProvider.notifier).confirmPickup() : null,
        ),
      ),
    );
  }
}
```

### 7.3 Rules (CI blocks these outside `packages/lane_ui`)

| ✗ Not allowed in app code | ✓ Use instead |
|---|---|
| `Color(0x…)`, `Colors.red` | `context.lane.color.signal.stop` |
| `TextStyle(…)`, `fontSize:` | `context.lane.text.body` (`.copyWith(color:)` only for colour) |
| `EdgeInsets.all(13)`, `SizedBox(height: 10)` | `lane.space.s12`, `Gap(lane.space.s8)` |
| `BorderRadius.circular(10)` | `lane.radius.r12` |
| `Duration(milliseconds: 300)` in UI | `lane.motion.standard` |
| `Text('Hello')` | `Text(l10n.key)` |
| `ElevatedButton`, `showDialog` | `LaneButton`, `LaneSheet` / `LaneConfirmSheet` |
| `CircularProgressIndicator` for page loads | `SkeletonBlock` |
| `HapticFeedback.*` | `LaneHaptics.*` |

`tool/lint_design.sh` greps for these patterns and fails the PR, and `tool/check_strings.dart` fails if any ARB key is missing in `hi` or `gu`.

### 7.4 Every screen handles these states
`loading` (skeleton) · `data` · `empty` (EmptyState + action) · `error` (ErrorState + retry / alternative) · `offline` (disabled actions + reason). Location screens also handle **permission denied**, **permission denied forever** (button to open settings) and **GPS off** (button to turn it on).

### 7.5 Check it in Widgetbook
Every new component or screen-specific widget gets a Widgetbook use-case in Day, Night, Glare and Saver, in en/hi/gu, at text scale 1.0 and 2.0.

### 7.6 Golden tests
Each screen gets one `alchemist` golden test (Day + Night + Hindi at 2.0 text scale). CI runs goldens in CI mode, so any visual change shows up in the PR as a diff that a reviewer must approve.

### 7.7 Test on a real phone
Test in sunlight (try Glare), at night, and with the battery below 15% (check Saver kicks in).

### 7.8 Performance check
Run Flutter DevTools on the low-end phone with no janky frames on scroll, dock drag or the rail animation.

### 7.9 Definition of Done (PR template checkbox list)
- [ ] Uses one Lane template and Lane components only; `lint_design.sh` passes
- [ ] All strings in ARB (en/hi/gu); `check_strings` passes
- [ ] loading / empty / error / offline states done (7.4)
- [ ] Widgetbook use-case + golden test added
- [ ] Checked at 200% text, TalkBack labels present
- [ ] Day / Night / Glare / Saver checked on device
- [ ] `flutter analyze` has 0 warnings; tests pass
- [ ] No new Firestore field or status outside sections 8–9
- [ ] Security checklist 12.14 ticked if the PR touches data, auth, files or functions

---

## 8. Firestore Data Model (shared contract)

General rules for every document:
- `createdAt` and `updatedAt` are server timestamps.
- `schemaVersion: 1`.
- The Dart model lives in `roadside_core`; the TypeScript type lives in `firebase/functions/src/models`. Both change in the same PR.

🔒 = only Cloud Functions or admin can write it (client writes are blocked by rules).

### `users/{uid}`: customers
- `name`, `phone` (from Auth, 🔒), `language` (`en` | `hi` | `gu`)
- `emergencyContacts`: list of `{ name, phone }` (max 3, E.164 format)
- `fcmToken`, `consent`: `{ version, acceptedAt }` (privacy-notice version the user agreed to)
- `deletionRequestedAt` (🔒, set by `requestAccountDeletion`)

### `users/{uid}/vehicles/{vehicleId}`
- `type` (`car` | `bike` | `scooter` | `ev`), `brand`, `model`, `regNo` (validated: Indian format or BH series), `fuel` (`petrol` | `diesel` | `cng` | `electric`), `isDefault`

### `mechanics/{uid}`: public-ish profile (readable by the mechanic themself and admins)
- `name`, `shopName`, `shopAddress`, `shopPhotoUrl`
- `cityId` (`ahmedabad` | `ankleshwar` | `bharuch`; chosen at registration, changed only by admin)
- `vehicleTypes`: list, `services`: list of problem types
- `status` 🔒 (`pending` | `approved` | `blocked`), `rating` 🔒, `ratingCount` 🔒, `jobsCompleted` 🔒
- `fcmToken`

### `mechanics/{uid}/private/kyc`: self (write once while `pending`) and admin read
- `phone` (🔒 from Auth), `idProofPath` (Storage path, not URL), `upiId`, `upiName`, `kycCheckedBy` 🔒, `kycCheckedAt` 🔒

### `presence/{uid}`: mechanic availability (self writes; Functions read)
- `isOnline`, `location`: `{ geopoint, geohash }`, `updatedAt`, `cityId` 🔒 (copied from the profile by Functions)
- `activeBookingId` 🔒 (null if free)
- Split from the profile so a mechanic can't edit their own `status` or `rating` while updating location.

### `offers/{offerId}`: what a mechanic sees *before* accepting (🔒, readable only by that mechanic)
- `bookingId`, `mechanicId`, `vehicleType`, `problemType`, `regNo`, `distanceKm`, `areaName` (locality only, no exact address), `priceEstimate`, `expiresAt`, `state` (`pending` | `accepted` | `declined` | `expired`)
- The exact pickup address and customer phone are revealed **only after accept**.

### `bookings/{bookingId}` (🔒 entirely; clients read, only Functions write)
- `customerId`, `mechanicId` (null until accepted), `cityId` (set by `createBooking` from the pickup point)
- `vehicle`: snapshot `{ type, brand, model, regNo }`
- `problemType` (`flat_tyre` | `battery` | `wont_start` | `overheating` | `accident` | `fuel` | `other`), `description`, `photoUrls`
- `pickup`: `{ geopoint, geohash, address, landmark, plusCode, accuracyMeters }`
- `status` (section 9), `statusHistory`: list of `{ status, at, by }`
- `currentOfferId`, `triedMechanicIds`, `searchRadiusKm` (3 → 5 → 10)
- `priceEstimate`: `{ min, max }` (computed by the server from `prices`, never sent by the client), `finalAmount`
- `mechanicCard`: snapshot set at accept `{ name, photoUrl, shopName, rating, jobsCompleted, phone, upiId, upiName }`
- `customerCard`: snapshot set at accept `{ name, phone }`
- `paymentStatus` (`pending` | `customer_marked_paid` | `confirmed` | `disputed`)
- `beforePhotoUrls`, `afterPhotoUrls`
- `timestamps`: `{ requested, accepted, arriving, arrived, started, completed, cancelled }`
- `cancelledBy` (`customer` | `mechanic` | `admin` | `system`), `cancelReason` (enum + optional text)
- `idempotencyKey` (from the client, so a double-tap doesn't create two bookings)

### `bookings/{bookingId}/private/otp` (🔒; readable only by the booking's customer)
- `code` (4 digits, from `crypto.randomInt`), `attempts`, `lockedUntil`
- The mechanic never reads it; they submit it to `verifyStartOtp`.

### `bookings/{bookingId}/messages/{messageId}`
- `senderId`, `text` (≤ 500 chars), `imagePath`, `createdAt`
- Participants can write only while the booking is active; read access stays for 30 days.

### `liveLocations/{bookingId}` (the assigned mechanic writes; the booking's customer reads)
- `mechanicGeopoint`, `heading`, `speed`, `etaMinutes`, `updatedAt`, `expireAt` (TTL: deleted 24 h after the job ends)

### `shareLinks/{token}` (🔒)
- `bookingId`, `createdBy`, `expiresAt` (at job end or 3 h, whichever comes first)
- `token` is 128-bit random. The public page calls `getSharedTrip(token)` and gets back only: mechanic first name, ETA, a coarse mechanic position and the status.

### `prices/{vehicleType_problemType}`
- `vehicleType`, `problemType`, `min`, `max`, `includes` (short text), `cityOverrides`: optional map `{ cityId: { min, max } }` (e.g. highway call-outs in Ankleshwar/Bharuch). Readable by signed-in users; only admins write.

### `serviceAreas/{cityId}` (readable by everyone; admins write)
- `name` (en/hi/gu), `center`: geopoint, `radiusKm` (Ahmedabad 25, Ankleshwar 12, Bharuch 12 to start; tune in the field test), `active` (bool), `supportPhone`, `launchedAt`
- Seed documents: `ahmedabad` (23.0225, 72.5714), `ankleshwar` (21.6264, 73.0152), `bharuch` (21.7051, 72.9959). Ankleshwar and Bharuch are about 12 km apart across the Narmada; a pickup inside both circles belongs to the nearer centre.

### `reviews/{bookingId}`
- `customerId`, `mechanicId`, `stars` (1–5), `tags`, `comment` (≤ 500 chars), `createdAt`. One per completed booking, created by that booking's customer only.

### `complaints/{complaintId}`
- `bookingId`, `raisedBy`, `category`, `text`, `status` (`open` | `resolved`), `resolution`, `createdAt`

### `inbox/{uid}/items/{itemId}` (🔒): the notifications list screen
- `type`, `titleKey`, `bodyKey`, `args`, `bookingId`, `read` (the owner may flip only `read`)

### `appConfig/public` (readable by everyone; admins write)
- `minSupportedBuild` (force update), `maintenanceMessage`, `supportPhone`, `dispatchEnabled` (kill switch)

### `auditLogs/{id}` (🔒, admin read)
- Every admin action (approve, block, price change, refund note): `{ actorUid, action, target, before, after, at }`

### `rateLimits/{uid}` (🔒, server only)

### Roles
Roles are **Firebase Auth custom claims** set only by Functions: `role: customer | mechanic | admin`, plus `mechanicStatus`.
- `admins/{uid}` is kept as a readable list for the admin panel, but rules trust the **claim**, not the document.
- The first admin is set with a one-off script by P3.

---

## 9. Booking Status Flow (shared contract)

```
requested ──► accepted ──► arriving ──► arrived ──► in_progress ──► completed
    │            │  ▲          │           │
    │            │  └──(mechanic cancels before arrival: re-dispatch, back to requested)
    ▼            ▼             ▼           ▼
no_mechanic_found            cancelled (by customer / admin; mechanic after arrival)
```

**Every status change happens inside a Cloud Function transaction** that checks the current status, the caller's role and the allowed transition (`roadside_core` exports the same table for the apps to use in UI logic).

| To status | Callable / trigger | Who | Server checks |
|---|---|---|---|
| `requested` | `createBooking` | Customer | Pickup inside an **active** service area (else `out_of_area` error → the 'not in your area yet' screen); no other active booking; vehicle belongs to caller; pickup accuracy ≤ 100 m or pin confirmed; rate limit; computes `priceEstimate` |
| `accepted` | `respondToOffer` | Mechanic | Offer is theirs, not expired, and they're approved, online and free (transaction prevents two accepts) |
| `arriving` | `startTrip` | Assigned mechanic | Status `accepted` |
| `arrived` | `markArrived` | Assigned mechanic | Server distance to pickup ≤ 100 m (≤ 200 m if pickup accuracy was poor) |
| `in_progress` | `verifyStartOtp` | Assigned mechanic | Code matches; max 5 attempts, then 10-minute lock and the customer is notified |
| `completed` | `completeJob` | Assigned mechanic | ≥ 1 after photo, `finalAmount` within 0.5–3× the estimate (else a reason is required) |
| `requested` (re-dispatch) | `cancelBooking` | Mechanic, before `arrived` | Mechanic added to `triedMechanicIds`; counts against reliability |
| `cancelled` | `cancelBooking` | Customer (any time before `in_progress`), mechanic (after `arrived` with reason), admin | Reason required |
| `no_mechanic_found` | Dispatch sweep | System | Nobody accepted up to 10 km |

Payment: `markPaid` (customer, after `completed`) moves it to `customer_marked_paid`, then `confirmPayment` (mechanic) moves it to `confirmed`, or `disputePayment` (either) moves it to `disputed` and opens a complaint.

UI colour per status: see the signal table in 6.7. The Journey Rail stops are Requested · Accepted · On the way · Arrived · Working · Done.

---

## 10. Features & Screens

Template names from 6.13 are in brackets.

### Common (built separately in each app from the same Lane templates)
- Splash
- Language select (big tiles showing each language in its own script)
- Onboarding (3 slides) [Status]
- Privacy notice & consent (DPDP, 12.12) [Form]
- Phone OTP login [Flow]
- Permissions explainer (prominent disclosure **before** each system prompt) [Status]
- Notifications list [List]
- Help & FAQ [List]
- Delete account [Form]

### Customer app: P1 (≈18 screens)
1. Home [Map]: map, current address, default vehicle chip (PlateChip), **Get Help** (Beacon, 64 dp), ☀ Glare, SOS, city chip (detected service area)
   - State: **Outside service area** [Status]: lists the 3 cities, 'Send location by SMS', 'Notify me when you launch here'
2. Add vehicle [Flow] / 3. My vehicles [List]
4. Problem picker [Flow]: 2-column `ProblemTile` grid, 7 problems
5. Photo + description, optional [Flow]: images compressed to ≤ 1600 px and ≤ 500 KB before upload, EXIF location stripped
6. Confirm location [Map]: draggable map under `CenterPin`, `AccuracyBadge`, landmark field, Plus Code
7. Price estimate [Flow]: `PriceRange` with what's included
8. Searching [Status]: `BreathingPulse`, radius shown as it widens, cancel
9. Mechanic assigned [Status → Map]: `TrustPass` slides up with the success haptic
10. Live tracking [Map]: `JourneyRail`, rolling ETA, gliding marker, Call / Chat, start code large
11. Chat
12. Job in progress [Status]: Working stop on the rail, elapsed time
13. Payment [Flow]: amount in mono display, "Pay with UPI app" (deep link) + QR + copy UPI ID, "I have paid"
14. Rate & review [Flow]
15. Booking history [List] / 16. Booking detail (vertical rail with times, receipt)
17. Emergency contacts [Form]
18. Profile & settings [Form]: language, ambient mode override, arrival chime, delete account

**Customer advanced features**
- **Emergency SOS:**
  - Hold to SOS (1.5 s).
  - Phase 1 opens the phone's SMS app **pre-filled** to all saved contacts with a message and live-trip link, and offers WhatsApp share and a call to 112. (Sending SMS silently needs the restricted `SEND_SMS` permission, which Play only allows for default SMS apps.)
  - Phase 2 option: server-sent SMS through a DLT-registered Indian SMS provider.
- **Share live trip link** with family (`shareLinks`, expires automatically).
- **SMS fallback when offline:** opens the SMS app pre-filled with coordinates and a map link to the support number.
- **Cancel protection:** a confirm sheet with a reason and a live "mechanic is N min away" line.

### Mechanic app: P2 (≈9 screens)
1. Registration [Flow]: city (Ahmedabad / Ankleshwar / Bharuch), shop details, shop photo, ID proof (private), services, UPI ID + name
2. Approval pending [Status]
3. Dashboard [List]: a big online/offline toggle (64 dp), today's jobs and earnings with `LaneRollingNumber`
4. Incoming request [Status, full screen]:
   - problem, plate, distance, area, price range
   - `CountdownRing` 30 s around `LaneSlideToConfirm`, plus Decline
5. Navigate to customer [Map]: route, "Open in Maps" hand-off, call, chat, **I've arrived**
6. Enter start code [Flow]: `LaneOtpInput`, then job in progress
7. Job complete [Flow]: before/after photos, final amount, slide to finish
8. Payment confirmation [Status]: "Customer says paid ₹450 — check your UPI app", then Confirm / Not received
9. Earnings & job history [List]

### Admin panel: P3 (≈6 screens, `ConsoleShell`, Night by default)
1. Dashboard: `StatCard`s for bookings today, active mechanics, completion rate, median arrival time, SMS success rate
2. Mechanic approvals: view documents through short-lived signed URLs; approve / block with a reason; every action is written to `auditLogs`
3. Live bookings map + booking list with filters and a vertical `JourneyRail` per booking
4. Price chart editor (validates min < max, preview)
5. Complaints & reviews
6. Settings: `appConfig` (force-update build, kill switch, support phone), **service areas** (switch each city on/off, radius), admin list (read only)
- Every admin list, map and dashboard has a **city filter** (All / Ahmedabad / Ankleshwar / Bharuch).

---

## 11. Location & Dispatch Rules (technical spec)

### Customer location accuracy
- Request `LocationAccuracy.best`; wait until accuracy ≤ **20 m** or a **15 s** timeout, then show `AccuracyBadge`.
- The user can always drag the map under the fixed centre pin; reverse-geocode the pin to an address, and generate a Plus Code for roads with no address.
- Save `accuracyMeters` in the booking. Reject pickups more than 2 km from the device's last fix unless the user confirms "I'm booking for someone else".

### Mechanic live location
- While **online and idle**: update `presence/{uid}.location` every **60 s** or **100 m**.
- During an **active job**: update `liveLocations/{bookingId}` every **5 s** or **10 m**. The customer app interpolates between fixes (6.5 ⑥).
- Use an Android **foreground service** of type `location` with a visible notification (the Live Update on Android 16) during active jobs. This avoids background-location permission.
- Stop all tracking when offline or when the job ends; the app also stops if `presence.updatedAt` is older than 2 minutes (the server marks the mechanic offline).

### Dispatch (Cloud Functions: P2, region `asia-south1`)
1. `createBooking` → finds approved, online, free mechanics **in the same `cityId`** that support the vehicle type and problem within **3 km** (GeoHash), sorted by distance, skipping `triedMechanicIds`. Highway pickups in Ankleshwar/Bharuch are common, so those two cities may also match mechanics from the other one when the radius reaches 10 km.
2. Creates an `offers/{id}` for the nearest one with `expiresAt = now + 30 s`, then sends a high-priority push.
3. `respondToOffer` (callable): accept → a transaction assigns the mechanic, sets `presence.activeBookingId`, and snapshots `mechanicCard` / `customerCard`. Decline → next mechanic.
4. A scheduled sweep every minute (plus a Cloud Tasks timer per offer for precision) moves expired offers on to the next mechanic.
5. Nobody left → widen the radius to **5 km**, then **10 km**, then `no_mechanic_found` (the customer is offered "Try again", "Call support" and "SMS").
6. `verifyStartOtp`, `markArrived`, `completeJob`, `cancelBooking`, `markPaid`, `confirmPayment` are as in section 9.
7. `onBookingStatusChange` pushes a notification to the other side and writes `inbox` items.
8. `onReviewCreated` updates the mechanic's average rating (transaction).
9. `appConfig.dispatchEnabled == false` → `createBooking` returns a friendly "service paused" error.

### Android permissions
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION` (mechanic app only)
- `POST_NOTIFICATIONS`, `CAMERA`, `INTERNET`
- `USE_FULL_SCREEN_INTENT` (mechanic offers; declare the use case in Play Console)
- **Not requested:** `ACCESS_BACKGROUND_LOCATION`, `READ_SMS`, `SEND_SMS`, `READ_CONTACTS`. Emergency contacts use the system contact picker, which needs no permission. OTP auto-fill uses the SMS Retriever API, which needs no SMS permission.

---

## 12. Security & Privacy (P3 leads; everyone follows)

### 12.1 Threat model (what we defend against)

| Threat | Control |
|---|---|
| Fake app or scripts calling our backend | **App Check** (Play Integrity on Android, reCAPTCHA Enterprise on admin web) **enforced** on Firestore, Storage, Functions and Auth |
| SMS pumping (bots triggering OTP SMS to premium numbers) | SMS region policy **allow-list India (+91) only**, App Check on Auth, a daily SMS budget alert, and a dashboard of SMS success rate (healthy is roughly 70–85%; below 50% means abuse) |
| Customer reads another customer's booking | Rules: bookings are readable only by `customerId`, `mechanicId` or an admin; rule tests cover it |
| Mechanic edits own `status`/`rating`, or fakes arrival or completion | Sensitive fields 🔒; all status changes go through Functions with server checks (section 9) |
| Two mechanics accept the same job | Firestore transaction in `respondToOffer` |
| Mechanic guesses the start code | 5 attempts, then lock + customer alert; the code is never readable by the mechanic |
| Fake mechanic shows up | Only approved and KYC-checked mechanics; `TrustPass` with photo; start code handed over in person |
| Stalking via live location | Location readable only by the booking's customer while it's active; TTL deletion after 24 h; share links expire; customers can never query mechanics or presence |
| Leaked ID documents | Storage path private to admin + owner; admins view via short-lived signed URLs; no public URLs |
| Stolen keys in the repo | Nothing secret in git; gitleaks + GitHub secret scanning with push protection; API keys restricted |
| Payment scam ("pay me extra") | Amount set by the mechanic in-app and shown to the customer; the UPI deep link carries that amount; dispute button → complaint; payee name shown from KYC |
| Abusive users / spam bookings | Rate limits (e.g. max 3 bookings an hour, 1 active), block via the admin (revokes tokens) |
| Admin account takeover | Google sign-in with 2-step verification required, allow-listed admin claim, every action audited |

### 12.2 Identity & roles
- Phone OTP for customers and mechanics. In dev, use Firebase **test phone numbers** (no real SMS, no cost).
- Custom claims (`role`, `mechanicStatus`) are set only by Functions: `onMechanicRegistered` sets `role: mechanic, mechanicStatus: pending`, and approval sets `approved`.
- **Block** = set the claim + `revokeRefreshTokens(uid)` + set `presence.isOnline=false`, so the user is signed out everywhere within an hour (the app also listens and signs out immediately).
- Account deletion requires a fresh login (re-auth within 5 minutes).

### 12.3 App Check
- `firebase_app_check`: Play Integrity provider in `prod`, debug provider in `dev`. Each member registers their debug token in the **dev** project console; debug tokens never go in git.
- Turn on enforcement in dev once metrics show only verified requests (by day 6), and in prod before the production submission (day 19).

### 12.4 Firestore rules principles (P3)
- **Deny by default.** Every match block is explicit; there's no wildcard allow.
- Validate every client write:
  - allowed keys: `request.resource.data.keys().hasOnly([...])`
  - changed keys: `request.resource.data.diff(resource.data).affectedKeys().hasOnly([...])`
  - types, string lengths, and list sizes (≤ 3 emergency contacts, ≤ 5 photos)
- Helper functions: `isSignedIn()`, `isSelf(uid)`, `hasRole(r)`, `isParticipant(booking)`, `isActive(booking)`.
- Example:

```
match /bookings/{id} {
  allow read: if isSignedIn() && (resource.data.customerId == request.auth.uid
                || resource.data.mechanicId == request.auth.uid || hasRole('admin'));
  allow write: if false;                      // only Cloud Functions (Admin SDK) write bookings
  match /private/otp {
    allow read: if get(/databases/$(database)/documents/bookings/$(id)).data.customerId == request.auth.uid;
    allow write: if false;
  }
}
match /presence/{uid} {
  allow read: if isSelf(uid) || hasRole('admin');
  allow update: if isSelf(uid) && hasRole('mechanic')
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isOnline','location','updatedAt']);
}
```

- **Rule tests** in `firebase/rules_tests/` (Jest + `@firebase/rules-unit-testing` on the emulator). At least one allow and one deny test per collection and role. CI runs them on every PR that touches rules or the data model.

### 12.5 Storage rules
- Paths:
  - `users/{uid}/bookings/{bookingId}/{file}`
  - `mechanics/{uid}/shop/{file}`
  - `mechanics/{uid}/kyc/{file}` (owner write-once, admin read)
  - `bookings/{bookingId}/work/{file}` (assigned mechanic)
  - `bookings/{bookingId}/chat/{file}` (participants)
- Every write: `request.resource.size < 5 * 1024 * 1024` and `request.resource.contentType.matches('image/(jpeg|png|webp)')`.
- Clients compress before upload, and strip EXIF (GPS, device) before upload.

### 12.6 Cloud Functions hardening (P2)
- Every callable function uses `onCall({ region: 'asia-south1', enforceAppCheck: true }, …)`. `verifyStartOtp`, `confirmPayment` and `requestAccountDeletion` also set `consumeAppCheckToken: true` (replay protection; adds a little latency, so only on these).
- First lines of every function: check `request.auth`, check the role claim, then parse input with a **zod** schema. Reject unknown fields.
- Status changes run in transactions; `createBooking` uses `idempotencyKey`.
- Rate limits in `rateLimits/{uid}` (sliding window) for createBooking, respondToOffer, verifyStartOtp, sendChat, getSharedTrip.
- Errors are thrown as `HttpsError` with a safe code and message key. No stack traces or internal data go to clients.
- Secrets (maps server key, future SMS provider key) come from `defineSecret()` (Secret Manager), never from env files in git.
- Functions run with a dedicated, least-privilege service account. Logs contain `uid` and `bookingId` only, never phone numbers, addresses or OTPs.

### 12.7 App hardening (P1, P2)
- Release builds: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`. Upload the symbols to Crashlytics. R8/minify on.
- `android:allowBackup="false"`, cleartext traffic disabled (network security config), exported components reviewed, App Links verified (`assetlinks.json` on the share domain).
- `FLAG_SECURE` (no screenshots or recents preview) on the OTP login, start code, KYC upload and payment screens.
- A logging wrapper (`LaneLog` in `roadside_core`) redacts phone numbers, OTPs and coordinates in release; there's no `print` in app code (lint `avoid_print`).
- Force update: at start, compare the build number with `appConfig.minSupportedBuild` and show a blocking `LaneStatusScaffold` with an "Update" button.
- Play App Signing on. The upload keystore and its passwords live in the client-owned password manager; they're **never** in git or CI logs.

### 12.8 Keys, config & repo hygiene (P3)
- `google-services.json` and `firebase_options*.dart` identify the project; they're not secrets, but the **API keys must be restricted**:
  - Android keys to package name + SHA-1 (dev and prod).
  - Browser keys to the admin domain.
  - Each key only to the APIs it needs.
- Map keys come in via `--dart-define-from-file=env/dev.json` (the file is git-ignored; `env/example.json` is committed).
- `.gitignore` covers `env/*.json` (except the example), `*.jks`, `*.keystore`, `key.properties`, `service-account*.json`, `.env*`, `build/`, `*.log`.
- GitHub:
  - secret scanning + **push protection** on
  - Dependabot alerts and weekly updates for pub, npm and Actions
  - gitleaks in CI
  - the `main` branch protected (section 14)
  - 2FA required for all members

### 12.9 OTP & payment specifics
- Start code: 4 digits from `crypto.randomInt(0, 10000)`, zero-padded, regenerated if the booking is re-dispatched.
- UPI:
  - Validate the ID format (`^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$`).
  - Show `upiName` beside the ID.
  - Deep link `upi://pay?pa=…&pn=…&am=…&cu=INR&tn=Booking <shortId>`. The app never asks for or stores any bank or card details.

### 12.10 Location privacy & retention

| Data | Kept for |
|---|---|
| `liveLocations` | 24 h after the job ends (Firestore TTL on `expireAt`) |
| `presence.location` | Overwritten; cleared when offline |
| Chat messages & photos | 90 days, then deleted by a scheduled function |
| Bookings (without live location) | 3 years (disputes, tax); anonymised after account deletion |
| KYC documents | Until 180 days after the mechanic leaves the platform, then deleted |
| Crash logs | Crashlytics default retention, no PII |

### 12.11 Admin panel security
- Google sign-in; access only with the `admin` claim (set by the P3 script). Admins must have 2-step verification on their Google account.
- Hosting headers in `firebase.json`:
  - a strict `Content-Security-Policy` (self + Firebase + map domains)
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy: camera=(), microphone=(), geolocation=()`
  - `X-Frame-Options: DENY`
- Every admin write goes through a callable that also writes to `auditLogs`.

### 12.12 Privacy & legal (India DPDP Act 2023 + DPDP Rules 2025)
The Rules were notified on 13 Nov 2025, and most obligations apply from **13 May 2027**. We launch before that, so we build compliant from day one.
- **Notice & consent screen** (en/hi/gu) before sign-up. It says, in plain language, what we collect (phone, name, location, vehicle, photos, ID for mechanics), why, how long we keep it, and how to withdraw or delete. Record `consent.version` + time.
- **Purpose limitation:**
  - Location is used only for dispatch and tracking.
  - Emergency contacts are used only for SOS and the trip link.
  - There are no ads SDKs.
- **Rights:** view profile data in the app, correct it, and **delete the account in-app** + a **web deletion page** (both required by Google Play). `requestAccountDeletion` deletes or anonymises within 30 days, keeping only what the law requires (the booking/tax record, anonymised).
- **Age:** users confirm they're 18+ (the Act needs verifiable parental consent under 18, which we don't support).
- **Grievance contact:** a named person + email in the app (Help) and the privacy policy.
- **Breach process** (`docs/runbooks/breach.md`): contain, then inform affected users and the Data Protection Board without delay, with the detailed report within 72 hours.
- Publish the **privacy policy** and **terms** (P3, `docs/`, hosted on the share domain) before the closed test.

### 12.13 Monitoring & incident response
- Crashlytics (crash-free users ≥ 99.5% target) and Performance Monitoring for start time and screen rendering.
- Cloud Monitoring alerts to the team email or WhatsApp group:
  - function error rate > 2%
  - dispatch sweep failing
  - SMS success rate < 60%
  - Firestore reads spike
- Budget alerts on the Blaze plan at ₹500, ₹1,000 and ₹2,000.
- Firestore point-in-time recovery (7 days) + weekly scheduled export to Storage in prod.
- Kill switches in `appConfig`: pause dispatch, maintenance message, force update.
- `docs/runbooks/`: breach, SMS abuse, dispatch outage, bad release rollback (halt staged rollout in Play Console).

### 12.14 Security checklist for PRs (tick in the PR template)
- [ ] No secrets, keys or keystores added; gitleaks passes
- [ ] New or changed fields added to section 8, the rules, rule tests, the Dart and TS models
- [ ] Client writes limited with `hasOnly` / `affectedKeys`; sensitive fields are 🔒
- [ ] Callable: auth + role + zod + App Check + rate limit + safe errors
- [ ] No PII in logs, analytics or crash reports
- [ ] New permission? Justified here in 11 and in the Play Console declaration

---

## 13. Play Store & compliance (P3)
- **Target API 36 (Android 16)**: required for new apps and updates submitted from 31 Aug 2026.
- **Data safety form:** list location, phone, name, photos and (for mechanics) ID; say it's encrypted in transit; give the deletion URL.
- **Foreground service declaration** (location type, mechanic app) with a short video of the active-job notification.
- **Full-screen intent declaration** for the mechanic offer.
- **Prominent disclosure** screen before each location, camera and notification permission prompt (the "Permissions explainer" screen).
- **Closed testing:** new personal developer accounts must run a closed test with **12 testers opted in for 14 consecutive days** before production. Upload the first build and start it by **day 6** (section 16). The team registers the Play Console account **in the client's name** and pays the fee from the year-1 platform package; the client completes Google's identity verification on day 1. An organisation account needs a D-U-N-S number, so decide on day 1.
- Store listing assets (P3 with P1): screenshots from the golden-test frames in Day + Night, feature graphic on Beacon, and localised text in en/hi/gu.

---

## 14. GitHub Workflow & CI
- One private repo, all three as collaborators, 2FA required.
- `main` is protected:
  - no direct pushes
  - PR + 1 approval (shared packages, `firebase/*.rules`, `PLAN.md`: **2 approvals via CODEOWNERS**)
  - CI must pass
  - linear history (squash merge)
- Branch names: `p1/confirm-location`, `p2/dispatch-function`, `p3/price-editor`, `lane/journey-rail`.
- Commit messages: `feat:`, `fix:`, `ui:`, `lane:`, `sec:`, `docs:`, `chore:` (e.g. `feat: add draggable pin to confirm location`).
- Small PRs (one feature each), merge **every day** (the 20-day plan needs a green `main` daily). Screenshots or a short screen recording are required for any UI PR.
- **Never commit:** `.env`, env JSON, service-account keys, keystores, API secrets, debug App Check tokens.
- GitHub Issues + a Projects board (To do / Doing / Review / Done). Every screen in section 10 is one issue, labelled `customer`, `mechanic`, `admin`, `lane`, `security`.

**CI (GitHub Actions, path-filtered so each app only runs its own jobs + shared ones):**

| Job | Runs when | Checks |
|---|---|---|
| `lane_ui` | `packages/lane_ui/**` changes | analyze, unit tests, golden tests, contrast test, Widgetbook builds |
| `core` | `packages/roadside_core/**` | analyze, tests (status machine, validators) |
| `<app>` | that app or a shared package changes | `dart format --set-exit-if-changed`, `flutter analyze` (0 warnings), tests, goldens, `lint_design.sh`, `check_strings`, debug build |
| `functions` | `firebase/functions/**` | `tsc`, eslint, unit tests against the emulator |
| `rules` | `firebase/*.rules` or `roadside_core` | rule tests on the emulator |
| `secrets` | every PR | gitleaks |

- **Versioning:** `lane_ui` and `roadside_core` follow semver in their `pubspec.yaml` with a `CHANGELOG.md`.
- **Breaking changes:** a component is marked `@Deprecated('Use X; removal in 0.N+1')` for one sprint before it's removed, so no app breaks overnight.
- **Deploys:**
  - Functions and rules go to **dev** automatically on merge.
  - Deploys to **prod** are done by P3 from a tagged release (`vX.Y.Z`) after the test checklist passes.
  - App releases go through Play staged rollout (10% → 50% → 100%).

---

## 15. Rules for Claude Code (copy into `CLAUDE.md`)
- Read `PLAN.md` before starting any task. For UI work, re-read section 6 (Lane) and 7 (recipe) every session.
- Only edit files inside your own folders (section 2). Never edit `packages/lane_ui` or `packages/roadside_core` unless you own them; propose changes through an issue.
- Build every screen from one Lane template (6.13) and Lane components (6.12). Use `context.lane` tokens. No raw colours, `TextStyle`, magic numbers, durations or hard-coded strings (7.3). Run `tool/lint_design.sh` before finishing.
- Follow the Firestore model (section 8) and status flow (section 9) exactly. Don't invent fields, collections or statuses; propose changes via a PLAN.md PR.
- Clients never write `bookings`, `offers`, OTPs, ratings or statuses. Those go through the callable functions in section 9.
- Every callable function: `enforceAppCheck`, an auth + role check, a zod-validated input, a transaction for status changes, and `HttpsError` with safe messages.
- Use Riverpod for state and `go_router` for navigation; follow the feature-first folder layout (section 5).
- All user-facing text goes through ARB files (en / hi / gu) with keys named `screen_element_purpose`.
- Handle loading / empty / error / offline on every screen, plus permission-denied and GPS-off on location screens.
- Never log or print phone numbers, OTPs, addresses or coordinates. Never add secrets to the repo.
- One feature per session; run `flutter analyze` (0 warnings), tests and golden tests before committing. Add a Widgetbook use-case and a golden test for new UI.
- When unsure about design, pick the calmer, bigger, simpler option (6.3).

---

## 16. Timeline (20 days: full scope, nothing removed)

The whole plan ships in **20 working days**. That's only possible because the three members work **in parallel from day 1** on the shared contract (sections 5–9, 12) and on `lane_ui`. Nobody waits for another person's screens; mock data comes from `roadside_core` fakes until the real Firestore wiring lands.

| Day | P1 (customer app + Lane) | P2 (mechanic app + Functions) | P3 (admin + Firebase + security) | Milestone |
|---|---|---|---|---|
| **1** | Lane tokens, fonts, `LaneApp`, ambient modes; Figma Foundations | Functions skeleton (auth/role/zod/App Check wrapper) | Repo, CODEOWNERS, CI; **dev + prod** Firebase in `asia-south1`; SMS region policy; **register the client's Play Console account** (paid from the platform package; client completes Google's ID verification) | Setup done · **Payment 1** |
| **2** | Wireframes reviewed with client (see `wireframes/`) → sign-off | `createBooking`, pricing | `roadside_core` models + status machine; rules v1 + tests | Wireframes signed off |
| 3–4 | `lane_ui` v0.1: templates + 12 core components + Widgetbook; login, language, consent | Mechanic registration, dashboard, online toggle, presence | Admin shell, approvals, price editor | Lane v0.1 |
| **5–6** | Home, vehicles, problem picker, confirm location, estimate | Dispatch v1 (offers, 30 s timeout, radius widening), `respondToOffer` | Storage rules, App Check (debug), Crashlytics; **upload first closed-test build and opt in 12 testers by day 6** | 14-day Play test clock starts |
| 7–9 | Searching, assigned (TrustPass), tracking (JourneyRail), chat | Incoming offer, navigate, arrive (`markArrived`), start code (`verifyStartOtp`), foreground service | Live bookings map, complaints, `appConfig`, audit log | — |
| **10** | **Two-phone end-to-end demo** (book → accept → track → complete → pay) in Day + Night | ← same | ← same | Client demo · **Payment 2** |
| 11–14 | Payment, rating, history, SOS, share trip, SMS fallback, Glare/Saver, 3 languages | Job complete, payment confirm, earnings, Live Update notification, re-dispatch on cancel | Account deletion (in-app + web), privacy policy + terms live, rate limits, TTL + retention jobs | Feature complete |
| 15–16 | Golden tests, TalkBack, 200% text, low-end phone perf | Functions tests, abuse tests | **Security review** (12.14, rule tests, SMS abuse, App Check enforced in prod) | Code freeze for features |
| 17–18 | **Field test in all 3 cities** (Ahmedabad, Ankleshwar, Bharuch; include NH-48 highway stretches) with 5–10 real mechanics per city (sun, night, low battery, weak network) → fixes | ← same | Store listing (en/hi/gu), Data safety, FGS + full-screen-intent declarations | — |
| **19–20** | Release builds (obfuscated), final regression | Prod deploy of Functions + rules (tagged `v1.0.0`) | Production submission in Play Console, handover pack | **Submitted + handed over · Payment 3** |

**Play Store timing (outside our control):**
- A **personal** Play Console account created after 13 Nov 2023 must run a closed test with **12 testers opted in for 14 consecutive days** before it can apply for production.
  - Starting the test on day 6 means production access can be requested on day 20.
  - Google's review then usually takes a few days.
- An **organisation** account is exempt from that test but needs a D-U-N-S number, which can take longer to get. So the client should decide on day 1.
- Either way, the code is complete and submitted on day 20, and public availability follows Google's review.

---

## 17. Testing Checklist (P3 maintains the full version in `docs/`)

**Flows**
- [ ] Login with OTP on a fresh install; OTP auto-fill works; wrong OTP handled
- [ ] Location accuracy on an open road, inside a building, GPS off, permission denied forever
- [ ] Booking when no mechanic is online → radius widens → `no_mechanic_found` with actions
- [ ] Mechanic ignores an offer → it moves to the next after 30 s
- [ ] Pickup outside all service areas → 'not in your area yet' screen; pickup between Ankleshwar and Bharuch → nearest city; switching a city off in admin blocks new bookings there
- [ ] Two customers booking at the same time; two mechanics accepting the same booking (only one wins)
- [ ] Wrong OTP rejected; 5 wrong attempts lock the code; the correct OTP starts the job
- [ ] Live tracking keeps working with the mechanic's screen off (foreground service)
- [ ] Cancel from both sides at every status; mechanic cancel before arrival re-dispatches
- [ ] SMS fallback and SOS messages contain the correct map link; share link expires at job end
- [ ] UPI deep link opens UPI apps with the right amount and payee; dispute opens a complaint
- [ ] Force update and dispatch kill switch work
- [ ] Account deletion (in-app and web) removes or anonymises data

**Design & accessibility**
- [ ] All three languages on every screen; no clipped Devanagari/Gujarati; 200% text scale
- [ ] Day / Night (auto at sunset) / Glare / Saver on real devices; outdoor sunlight test
- [ ] TalkBack pass on the booking flow; all icon buttons labelled
- [ ] 60 fps on the low-end phone: map dock drag, rail animation, lists
- [ ] Golden tests green; no unreviewed visual diffs

**Security**
- [ ] Rules: a customer can't read another customer's booking, OTP, or any mechanic or presence doc
- [ ] Rules: a mechanic can't read a booking before accepting, can't write status, rating, or `activeBookingId`
- [ ] Callables reject calls without App Check, without auth, with the wrong role, or with extra or invalid fields
- [ ] Storage rejects non-images, files > 5 MB, and writes to other users' paths; KYC isn't readable by customers
- [ ] No PII in Crashlytics or function logs; gitleaks clean; API keys restricted
- [ ] SMS region policy blocks non-+91 numbers

---

## 18. Scope & Budget
- **Price to the client: ₹30,000 all-inclusive for year one** (client proposal: `proposal/Proposal.pdf`).
  - **Development: ₹25,000.** Customer app ₹8,500 · Mechanic app ₹5,000 · Admin panel ₹3,000 · Backend & dispatch ₹4,000 · Lane design system & languages ₹2,000 · Security, privacy & Play Store submission ₹2,500.
  - **Year-1 platform package: ₹5,000.** We (the team) set up, pay and manage Google Play Console registration + Firebase for 12 months from launch. The accounts are registered in the client's name; our card is on the Firebase billing account for year 1.
- **Payment milestones** (on ₹30,000):
  - 40% at start (₹12,000; this also funds the Play Console fee)
  - 30% at the day-10 demo (₹9,000)
  - 30% at Play Store submission + handover on day 20 (₹9,000)

**How the ₹5,000 is spent** (Sep 2026 prices, $1 ≈ ₹85; 3 cities, ~300 bookings a month in total):

| Item | Cost | Covered by package |
|---|---|---|
| Google Play Console registration | US$25 ≈ ₹2,100 one time | ✓ |
| Firebase Blaze (Firestore, Functions, Hosting, Storage in `asia-south1`) | ≈ ₹125–250 a month (mostly within free quotas: 50K reads / 20K writes a day, 2M function calls a month) | ✓ |
| Phone-auth OTP SMS (≈ US$0.07 ≈ ₹6 each) | Grows with new users | ✓ fair use (see below) |
| FCM, Crashlytics, App Check, Remote Config | Free | ✓ |
| Ola Maps | ₹0 inside the 100K events-a-month free tier | ✓ |
| Privacy / deletion / share pages | ₹0 on Firebase Hosting (`*.web.app`); a custom domain (≈ ₹800–1,200 a year) is optional and not included | — |

⚠ **Team risk to watch (P3 owns this).**
- After the Play fee, about ₹2,900 is left for 12 months of Firebase. That covers the infrastructure plus roughly 200–250 OTP SMS.
- Heavier OTP use (for example 1,000+ logins) would cost the team ₹6,000–9,000.
- Mitigations:
  - Use Firebase test numbers in dev.
  - Keep users logged in.
  - Keep the SMS region policy at India-only.
  - Set a budget alert at ₹250 / ₹500 a month.
  - Invoke the proposal's fair-use clause (notify the client before any extra charge) if growth passes launch scale.
  - Plan a cheaper DLT OTP provider for year 2 if needed.

**Year 2 and later:** at the same scale, running costs are ≈ ₹7,500–15,000 a year. The client either takes over the billing or renews a yearly package; send the quote 1 month before year 1 ends.
- **Support:** bug fixes for 1 month after launch; new features quoted separately
- **Phase 2 (not included):**
  - WhatsApp bot booking
  - AI problem diagnosis
  - in-app payments with commission
  - server-sent SOS SMS via a DLT-registered provider
  - masked calling between customer and mechanic
  - iOS apps
  - towing partners
  - insurance tie-ups

---

## 19. References
- ThreeUI Community (MIT; fonts, buttons, backgrounds): https://github.com/MengTo/threeui
- Google Play 12-testers / 14-days rule: https://support.google.com/googleplay/android-developer/answer/14151465
- Firebase pricing (Blaze no-cost quotas): https://firebase.google.com/pricing
- Anek multi-script type family (OFL): https://github.com/EkType/Anek · https://design.google/library/anek-multiscript
- Android 16 progress-centric notifications (Live Updates): https://developer.android.com/about/versions/16/features/progress-centric-notifications
- Google Play target API level policy: https://support.google.com/googleplay/android-developer/answer/11926878
- Google Play account deletion requirement: https://support.google.com/googleplay/android-developer/answer/13327111
- Firebase App Check for Cloud Functions: https://firebase.google.com/docs/app-check/cloud-functions
- SMS region policy (anti SMS-pumping): https://docs.cloud.google.com/identity-platform/docs/admin/sms-regions
- Widgetbook: https://github.com/widgetbook/widgetbook · Alchemist golden tests: https://github.com/Betterment/alchemist
- Ola Maps pricing & Flutter plugin: https://maps.olakrutrim.com/pricing · https://pub.dev/packages/ola_maps
- DPDP Rules 2025 timeline (summary): https://www.sansalegal.com/post/dpdp-act-2023-and-rules-2025-phased-implementation-timeline-and-business-compliance-deadlines

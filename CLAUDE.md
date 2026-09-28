# CLAUDE.md: rules for every Claude Code session in this repo

(Copied from PLAN.md §15. If they differ, PLAN.md wins.)

- Read `PLAN.md` before starting any task. For UI work, re-read §6 (Lane) and §7 (recipe) every session. Check the matching frame in `wireframes/Wireframes.pdf` (screen IDs C1–C10, U1–U18, M1–M9, A1–A6).
- Only edit files inside your own folders (PLAN.md §2):
  - P1 (@CODER7657): `customer_app/`, `packages/lane_ui/`, `design/`
  - P2 (Hem, @Hem60): `mechanic_app/`, `firebase/functions/`
  - P3 (Ayush, @Ayush3422): `admin_panel/`, `packages/roadside_core/`, `firebase/*`, `.github/`, `docs/`, `tool/`
- Never edit `packages/lane_ui` or `packages/roadside_core` unless you own them; propose changes through an issue.
- Build every screen from one Lane template (§6.13) and Lane components (§6.12). Use `context.lane` tokens. No raw colours, `TextStyle`, magic numbers, durations or hard-coded strings (§7.3). Run `tool/lint_design.sh` before finishing.
- Buttons follow the ThreeUI styles in §6.12:
  - primary = Launch Button (amber gradient + ledge)
  - secondary = Spinning Border (zinc pill)
  - SOS hold = Gradient Beam ring
- Icons are Phosphor duotone (`phosphor_flutter`), with ink line and Beacon fill.
- Follow the Firestore model (§8) and status flow (§9) exactly. Don't invent fields, collections or statuses; propose changes via a PLAN.md PR.
- Every booking, mechanic and presence record carries a `cityId` (`ahmedabad` | `ankleshwar` | `bharuch`). Pickups outside an active `serviceAreas/{cityId}` are rejected.
- Clients never write `bookings`, `offers`, OTPs, ratings or statuses. Those go through the callable functions in §9.
- Every callable function has:
  - `enforceAppCheck`
  - an auth + role check
  - a zod-validated input
  - a transaction for status changes
  - `HttpsError` with safe messages
  - region `asia-south1`
- Use Riverpod for state and `go_router` for navigation; follow the feature-first folder layout (§5).
- All user-facing text goes through ARB files (en / hi / gu) with keys named `screen_element_purpose`.
- Handle loading / empty / error / offline on every screen, plus permission-denied and GPS-off on location screens.
- Never log or print phone numbers, OTPs, addresses or coordinates. Never add secrets, keystores or env files to the repo.
- One feature per session. Before committing:
  - `flutter analyze` shows 0 warnings
  - tests and golden tests pass
  - new UI has a Widgetbook use-case and a golden test
- **One issue = one branch = one PR.** Branch name: `<owner>/<issue>-<short-name>` (e.g. `p1/12-confirm-location`). The PR description has exactly one `Closes #<issue>`. Never open a second PR for an issue that already has one: push to the existing branch instead. If the work is too big, stop and ask for the issue to be split.
- Commit style: `feat:`, `fix:`, `ui:`, `lane:`, `sec:`, `docs:`, `chore:`, `test:`, `ci:`.
- When unsure about design, pick the calmer, bigger, simpler option (§6.3).

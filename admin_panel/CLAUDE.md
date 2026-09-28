# admin_panel — P3 (Ayush)

Read the root `CLAUDE.md` first; this adds admin rules.

- Create with `flutter create --platforms web admin_panel` (this file survives). Hosted on Firebase Hosting with the headers in PLAN §12.11.
- Screens A1–A6 in `wireframes/Wireframes.pdf`: `ConsoleShell`, Night "control room" palette by default, 12-col grid, **city filter on every list/map** (All / Ahmedabad / Ankleshwar / Bharuch).
- A2 approvals: **type filter (Workshop / Independent)** with a per-type checklist (PLAN §10.0). Independent: Approve disabled until selfie↔ID match is ticked and a verification call is logged (callable sets `verificationCall` 🔒). A1/A3 show counts/markers by type.
- **Admins only (PLAN §12.11):** the Google sign-in allow-list (`beforeSignIn` blocking function) + `role: admin` claim (granted only by `tool/grant_admin`). No phone login, no sign-up, no self-service role. Non-admin sessions → A0 "Not authorised" + sign out. Every admin write goes through a callable that checks the claim and writes `auditLogs`.
- KYC documents only via short-lived signed URLs. Never download them to disk.
- Before every PR: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`, `bash ../tool/lint_design.sh lib`.

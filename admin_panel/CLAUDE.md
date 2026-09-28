# admin_panel — P3 (Ayush)

Read the root `CLAUDE.md` first; this adds admin rules.

- Create with `flutter create --platforms web admin_panel` (this file survives). Hosted on Firebase Hosting with the headers in PLAN §12.11.
- Screens A1–A6 in `wireframes/Wireframes.pdf`: `ConsoleShell`, Night "control room" palette by default, 12-col grid, **city filter on every list/map** (All / Ahmedabad / Ankleshwar / Bharuch).
- Access: Google sign-in + `admin` custom claim only. Every admin write goes through a callable that also writes `auditLogs`.
- KYC documents only via short-lived signed URLs. Never download them to disk.
- Before every PR: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`, `bash ../tool/lint_design.sh lib`.

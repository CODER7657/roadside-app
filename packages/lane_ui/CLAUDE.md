# packages/lane_ui — P1 (@CODER7657). Shared by all three apps: changes need P2 + P3 approval (CODEOWNERS)

- Create with `flutter create --template=package packages/lane_ui` (this file survives). Start from `design/lane_tokens.dart` and `design/tokens.json`.
- Everything in PLAN §6: tokens as `ThemeExtension`, `context.lane`, `AmbientController` (Day/Night/Glare/Saver), fonts from `assets/fonts/` (declare in pubspec with OFL texts), Phosphor duotone icons, ThreeUI button styles (§6.12), templates (§6.13), `LaneHaptics`, component strings in `lib/l10n` (en/hi/gu).
- Public API only via `lib/lane_ui.dart`; internals under `lib/src/`. Breaking change = `@Deprecated` for one sprint first + CHANGELOG + semver bump.
- Every component: Widgetbook use-case (Day/Night/Glare/Saver × en/hi/gu × text 1.0/2.0) + alchemist golden + contrast test.
- Performance: animate transform/opacity only; `RepaintBoundary` around dock and rail; 60 fps on a 3 GB RAM phone.

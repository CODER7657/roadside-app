# packages/lane_ui — P1 (@CODER7657). Shared by all three apps: changes need P2 + P3 approval (CODEOWNERS)

- Create with `flutter create --template=package packages/lane_ui` (this file survives). Tokens live in `lib/src/tokens/` and are mirrored in `design/tokens.json` (`test/tokens_json_test.dart` fails if they drift: change both in one PR).
- Everything in PLAN §6: tokens as `ThemeExtension`, `context.lane`, `AmbientController` (Day/Night/Glare/Saver), fonts from `assets/fonts/` (declare in pubspec with OFL texts), Phosphor duotone icons (`LaneIcon(LaneIcons.x)`, SVGs in `assets/icons/` via flutter_svg; add new ones from `@phosphor-icons/core`), ThreeUI button styles (§6.12), templates (§6.13), `LaneHaptics`, component strings in `lib/l10n` (en/hi/gu).
- Public API only via `lib/lane_ui.dart`; internals under `lib/src/`. Breaking change = `@Deprecated` for one sprint first + CHANGELOG + semver bump.
- Every component: Widgetbook use-case (Day/Night/Glare/Saver × en/hi/gu × text 1.0/2.0) + alchemist golden + contrast test.
- Badges: label in `ink` on a signal tint; the signal colour is only for the icon and dot (Day `route` is 4.4:1 on its tint). `test/contrast_test.dart` enforces it.
- Goldens (`test/goldens/`, alchemist CI mode): after an intended visual change run `flutter test --update-goldens` and commit the PNGs; a failing golden writes a diff under `test/goldens/failures/` (CI uploads it). Remember: Lane text styles carry `ink`, so text on a Beacon or signal fill must `copyWith(color: onBeacon / onSignal)`.
- CI goldens don't render opacity (alchemist's text-blocking paint pass) or shadows: assert disabled/faded states in widget tests instead.
- Buttons: `LaneButton.primary / secondary / pill / ghost / danger`, `critical: true` for 64 dp; `LaneHoldButton` (SOS) and `LaneSlideToConfirm` take their semantics text from the app.
- Component strings: add keys to `lib/l10n/lane_en.arb` (+ hi, gu) and run `flutter gen-l10n`; read them with `laneStrings(context)`.
- TalkBack: a live region needs `Semantics(container: true, liveRegion: true)`, and anything faded in needs `alwaysIncludeSemantics` so it's announced at once.
- Widgetbook: `cd widgetbook && flutter run -d chrome`.
- Run locally: `flutter analyze --fatal-infos`, `flutter test`, and `cd example && flutter run` to see Day/Night/Glare/Saver × en/hi/gu.
- Performance: animate transform/opacity only; `RepaintBoundary` around dock and rail; 60 fps on a 3 GB RAM phone.

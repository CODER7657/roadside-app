# Changelog

## 0.1.0-dev.3

Widgetbook and golden tests (#9), PLAN §7.5–§7.6.

- `widgetbook/`: the catalogue app. Every use case switches Day / Night / Glare / Saver,
  en / hi / gu and text scale 1.0–2.0 from the addon panel.
- Golden tests (`test/goldens/`, alchemist CI mode, so images match on every OS) for the
  specimen and all five templates in the four modes plus Hindi at 200%.
- `LanePreview` in `specimen.dart`: one phone frame for a given mode, locale and text scale,
  shared by goldens and Widgetbook.
- Fixed: the sample Beacon button label used `ink` (light in Night) instead of `onBeacon`.

## 0.1.0-dev.2

Screen templates (#8), PLAN §6.13.

- `LaneMapScaffold` + `LaneDock`: full-screen map, floating buttons top right, dock snapping
  between peek / half / full, primary pinned full width at 64 dp, 16 dp above the safe area.
  The map overlay (pin) stays centred in the visible map area as the dock moves;
  `onDockExtentChanged` gives the camera padding.
- `LaneFlowScaffold` (step label + `LaneStepLane` progress, sticky primary above the
  keyboard), `LaneStatusScaffold` (optional ThreeUI background under a ≥ 60% scrim),
  `LaneListScaffold` (required empty state, filters, pull to refresh), `LaneFormScaffold`.
- `LaneActionBar` and `LaneBackButton` (localised label) shared by the templates.
- `LaneTemplateSample` in `specimen.dart`; the example app opens every template.

## 0.1.0-dev.1

Lane foundations (#4).

- Tokens from PLAN §6.7–§6.11 in `lib/src/tokens/`: colours for Day / Night / Glare / Saver
  with signal tints, type scale, space, radius, touch targets, shadows, strokes, motion
  (full and reduced) and `LaneHaptics`.
- Bundled fonts (Onest, Instrument Serif, JetBrains Mono, Anek Devanagari / Gujarati) with
  OFL texts; `LaneText` switches family and `scriptMetrics` for hi / gu.
- `LaneTheme` (`ThemeExtension`) and `context.lane`; motion is reduced automatically when
  the system asks.
- `AmbientController` (Riverpod): manual > Saver (battery ≤ 15% or battery saver) > Glare >
  Night (local sunset, computed offline, or system dark) > Day.
- `LaneApp` / `LaneApp.router`: theme cross-fade, hi/gu type, text scale clamped at 200%,
  shared-axis page transitions, OfflineStrip slot, third-party notices on the licenses page.
- `package:lane_ui/specimen.dart` + `example/`: every mode and type style in en / hi / gu.

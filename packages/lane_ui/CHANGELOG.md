# Changelog

## 0.1.0-dev.6

Loading, empty, error and feedback (#85, part 3 of 4), PLAN §6.12, §6.5 ⑩, §7.4.

- Lane's own strings via gen-l10n (`lib/l10n/lane_{en,hi,gu}.arb` → `LaneLocalizations`);
  `LaneApp` and `LanePreview` add the delegate; components fall back to English.
- `SkeletonBlock` (still, no shimmer; outlined in Glare) and `SkeletonGroup` (announced once
  as "Loading").
- `EmptyState` (hero title, required action) and `ErrorState` (calm icon, default
  title and "Try again", optional alternative such as SMS).
- `LaneToast`: inverse fill above an optional dock offset, 4 s, one at a time, announced
  immediately.
- `OfflineStrip` + `LaneApp(offline:)`: neutral strip under the status bar that says what
  still works; the screen loses its duplicate top padding. The `offlineStrip:` slot still
  works.
- Fixed: the route's BlockSemantics hid anything above the screen from TalkBack; the screen
  now sits in its own semantics container.

## 0.1.0-dev.5

Inputs, chips and badges (#84, part 2 of 4), PLAN §6.12.

- `LaneTextField`: label above, 56 dp sunken field, helper or error below (error in
  `signal.stop`, announced as a live region); focus is a 2 px `ink` ring.
- `LaneChip` (solid `ink` when selected, 48 dp, selection haptic), `LaneSwitch` (whole row
  toggles; `big` is the 64 dp online toggle), `LaneListTile` (56 dp, two-line titles).
- `SignalBadge` + `LaneSignal`: colour + icon + word, `ink` label on the tint, outline in
  Glare. Placeholder Material icons until Phosphor (#86).
- `PlateChip`: fixed white/black Indian plate with IND band; `PlateChip.format` spaces
  standard and BH-series numbers; read letter by letter; scales down, never truncates.

## 0.1.0-dev.4

Buttons and gestures (#7, part 1 of 4), PLAN §6.12, §6.5 ⑤, §6.11.

- `LaneButton.primary` (ThreeUI Launch: amber gradient, ring, ledge; face drops 2 dp on
  press without moving the layout), `.secondary` (Spinning Border; Beacon beam while
  loading, spinning only with motion on), `.pill` (Gradient CTA), `.ghost`, `.danger` (flat
  `signal.stop`). `critical: true` for 64 dp; `loading` keeps the width and shows a spinner.
- `LaneHoldButton`: 1.5 s hold fills a Gradient Beam ring in `signal.stop`, fires once with
  the alert haptic; early release cancels; screen readers confirm with long-press.
- `LaneSlideToConfirm`: 64 dp track, confirm past 85%, spring back otherwise, confirm by
  double tap with a screen reader.
- Labels always set their own colour (never inherited `ink`); goldens and Widgetbook cover
  every variant.

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

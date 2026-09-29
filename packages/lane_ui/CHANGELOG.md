# Changelog

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

/// Lane, the design system shared by all three apps (PLAN.md §6).
///
/// Apps import only this file:
/// ```dart
/// import 'package:lane_ui/lane_ui.dart';
/// ```
/// and read tokens with `context.lane` (`.color`, `.text`, `.space`, `.radius`, `.motion`).
library;

export 'package:gap/gap.dart' show Gap, MaxGap, SliverGap;

export 'src/ambient/ambient_controller.dart'
    show
        AmbientController,
        AmbientState,
        ambientControllerProvider,
        ambientTick,
        laneBatterySourceProvider,
        laneClockProvider,
        laneModeProvider,
        resolveLaneMode,
        saverBatteryThreshold;
export 'src/ambient/battery.dart' show LaneBatterySource, LaneBatteryStatus, PlusBatterySource;
export 'src/ambient/solar.dart' show LanePosition, PolarDay, SolarDay, isNightAt;
export 'src/app/lane_app.dart' show LaneApp;
export 'src/app/lane_licenses.dart' show LaneLicenses;
export 'src/components/lane_button.dart' show LaneButton;
export 'src/components/lane_gestures.dart' show LaneHoldButton, LaneSlideToConfirm;
export 'src/templates/lane_action_bar.dart' show LaneActionBar, LaneBackButton;
export 'src/templates/lane_map_scaffold.dart' show LaneDock, LaneDockSnap, LaneMapScaffold;
export 'src/templates/lane_page_scaffolds.dart'
    show LaneFlowScaffold, LaneFormScaffold, LaneListScaffold, LaneStatusScaffold, LaneStepLane;
export 'src/theme/lane_theme.dart'
    show LaneContext, LaneMode, LanePageTransitionsBuilder, LaneTheme, LaneThemeData;
export 'src/tokens/lane_colors.dart' show LaneBrand, LaneColors, LaneSignals;
export 'src/tokens/lane_haptics.dart' show LaneHaptics;
export 'src/tokens/lane_layout.dart' show LaneRadius, LaneShadows, LaneSpace, LaneStroke, LaneTouch;
export 'src/tokens/lane_motion.dart' show LaneMotion;
export 'src/tokens/lane_text.dart' show LaneFonts, LaneScript, LaneScriptMetrics, LaneText;

# lane_ui

Lane, the design system shared by the customer app, mechanic app and admin panel. The rules
are in [PLAN.md §6–§7](../../PLAN.md); this package is the code.

```yaml
# pubspec.yaml of an app
dependencies:
  lane_ui:
    path: ../packages/lane_ui
```

```dart
import 'package:lane_ui/lane_ui.dart';

void main() => runApp(const ProviderScope(child: RoadsideApp()));

class RoadsideApp extends ConsumerWidget {
  const RoadsideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LaneApp.router(
    routerConfig: ref.watch(routerProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

// In any screen:
final lane = context.lane;
Text(l10n.tracking_eta_label, style: lane.text.caps);
Gap(lane.space.s16);
```

- **Tokens:** `lane.color` (with `.signal`), `lane.text`, `lane.space`, `lane.radius`,
  `lane.touch`, `lane.motion`, `lane.shadow`, `lane.stroke`.
- **Ambient modes:** `ref.read(ambientControllerProvider.notifier)` has `setManual`,
  `toggleGlare` (the ☀ button) and `updatePosition` (call it with location fixes so Night
  starts at local sunset).
- **Haptics:** `LaneHaptics.select() / press() / statusAdvance() / alert() / error()`.

See every mode and type style in en / hi / gu:

```bash
cd packages/lane_ui/example
flutter run
```

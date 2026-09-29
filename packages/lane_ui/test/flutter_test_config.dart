// Golden tests run in alchemist's CI mode everywhere: text is drawn as blocks and shadows
// are flattened, so the committed images match on Windows, macOS and the Linux CI runner.
// Regenerate after an intended visual change:  flutter test --update-goldens
import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) => AlchemistConfig.runWithConfig(
  config: const AlchemistConfig(
    platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ciGoldensConfig: CiGoldensConfig(enabled: true),
  ),
  run: () async => testMain(),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui_widgetbook/main.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

void main() {
  testWidgets('catalogue opens a template use case in Night + Hindi without errors', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [laneBatterySourceProvider.overrideWithValue(_NoBattery())],
        child: const LaneWidgetbook(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('LaneFlowScaffold'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(LaneFlowScaffold), findsOneWidget);
  });
}

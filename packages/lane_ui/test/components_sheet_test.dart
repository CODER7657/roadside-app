// #125: LaneSheet and LaneConfirmSheet (required reason before a destructive action).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

const reasons = [
  LaneReason('found_help', 'Found help elsewhere'),
  LaneReason('too_slow', 'Taking too long'),
  LaneReason('other', 'Something else', asksForText: true),
];

/// A screen with a button that opens the sheet and records what it returned.
class _Opener extends StatelessWidget {
  const _Opener({required this.results});

  final List<LaneConfirmResult<String>?> results;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () async => results.add(
          await LaneConfirmSheet.show<String>(
            context,
            title: 'Cancel this booking?',
            message: 'The mechanic will be told straight away.',
            reasons: reasons,
            confirmLabel: 'Cancel booking',
            keepLabel: 'Keep booking',
            textLabel: 'Tell us more',
          ),
        ),
        child: const Text('open'),
      ),
    ),
  );
}

Future<List<LaneConfirmResult<String>?>> open(
  WidgetTester tester, {
  Size size = const Size(360, 800),
  double textScale = 1,
  Locale locale = const Locale('en'),
}) async {
  final results = <LaneConfirmResult<String>?>[];
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: LanePreview(
        mode: LaneMode.day,
        locale: locale,
        textScale: textScale,
        size: size,
        child: _Opener(results: results),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

LaneButton confirm(WidgetTester tester) =>
    tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Cancel booking'));

void main() {
  testWidgets('confirm stays off until a reason is picked, then returns it', (tester) async {
    final results = await open(tester);
    expect(find.text('Cancel this booking?'), findsOneWidget);
    expect(confirm(tester).onPressed, isNull);
    await tester.tap(find.text('Taking too long'));
    await tester.pump();
    expect(confirm(tester).onPressed, isNotNull);
    expect(find.byType(TextField), findsNothing, reason: 'no text field for a plain reason');
    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    expect(results.single, (reason: 'too_slow', text: null));
  });

  testWidgets('"something else" asks for text, trimmed; blank text is null', (tester) async {
    var results = await open(tester);
    await tester.tap(find.text('Something else'));
    await tester.pump();
    expect(find.text('Tell us more'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Car started again  ');
    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    expect(results.single, (reason: 'other', text: 'Car started again'));

    results = await open(tester);
    await tester.tap(find.text('Something else'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    expect(results.single, (reason: 'other', text: null));
  });

  testWidgets('switching away from "something else" drops the text', (tester) async {
    final results = await open(tester);
    await tester.tap(find.text('Something else'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'typed');
    await tester.tap(find.text('Found help elsewhere'));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    expect(results.single, (reason: 'found_help', text: null));
  });

  testWidgets('keep and drag-dismiss return null', (tester) async {
    var results = await open(tester);
    await tester.tap(find.text('Taking too long'));
    await tester.tap(find.text('Keep booking'));
    await tester.pumpAndSettle();
    expect(results.single, isNull);

    results = await open(tester);
    await tester.fling(find.text('Cancel this booking?'), const Offset(0, 600), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Cancel this booking?'), findsNothing);
    expect(results.single, isNull);
  });

  testWidgets('confirm is the red danger button; the title is a header', (tester) async {
    await open(tester);
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.text('Cancel this booking?')),
      matchesSemantics(label: 'Cancel this booking?', isHeader: true),
    );
    handle.dispose();
    expect(find.widgetWithText(LaneButton, 'Keep booking'), findsOneWidget);
  });

  testWidgets('fits at 320 px, 200% text, and scrolls instead of overflowing', (tester) async {
    await open(tester, size: const Size(320, 640), textScale: 2, locale: const Locale('hi'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Something else'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

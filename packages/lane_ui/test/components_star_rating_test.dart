// #134: StarRating.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsAction, SemanticsNode;
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

/// Holds the value like a screen would.
class _Host extends StatefulWidget {
  const _Host({this.initial = 0, this.enabled = true, this.onChange});

  final int initial;
  final bool enabled;
  final ValueChanged<int>? onChange;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int value = widget.initial;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: StarRating(
        value: value,
        label: 'Rating for Kiran',
        onChanged: widget.enabled
            ? (v) {
                widget.onChange?.call(v);
                setState(() => value = v);
              }
            : null,
      ),
    ),
  );
}

Future<void> pumpIn(
  WidgetTester tester,
  Widget child, {
  LaneMode mode = LaneMode.day,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: LanePreview(mode: mode, locale: locale, child: child),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('tap a star to rate; each star is a 48 dp target', (tester) async {
    final changes = <int>[];
    await pumpIn(tester, _Host(onChange: changes.add));
    for (var i = 1; i <= 5; i++) {
      expect(tester.getSize(find.byKey(ValueKey('star-$i'))), const Size(48, 48));
    }
    await tester.tap(find.byKey(const ValueKey('star-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('star-4')));
    await tester.pumpAndSettle();
    expect(changes, [4], reason: 'tapping the same star again changes nothing');
    await tester.tap(find.byKey(const ValueKey('star-1')));
    await tester.pumpAndSettle();
    expect(changes, [4, 1]);
  });

  testWidgets('TalkBack: one slider, adjustable, within 1–5', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIn(tester, const _Host(initial: 0));
    SemanticsNode node() => tester.getSemantics(find.byType(StarRating));
    expect(node().label, 'Rating for Kiran');
    expect(node().value, 'Not rated yet');
    expect(node().flagsCollection.isSlider, isTrue);

    tester.semantics.performAction(find.semantics.byLabel('Rating for Kiran'), SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(node().value, '1 of 5 stars');

    for (var i = 0; i < 6; i++) {
      final n = node();
      if (!n.getSemanticsData().hasAction(SemanticsAction.increase)) break;
      tester.semantics.performAction(find.semantics.byLabel('Rating for Kiran'), SemanticsAction.increase);
      await tester.pumpAndSettle();
    }
    expect(node().value, '5 of 5 stars');
    expect(node().getSemanticsData().hasAction(SemanticsAction.increase), isFalse, reason: 'no 6th star');

    tester.semantics.performAction(find.semantics.byLabel('Rating for Kiran'), SemanticsAction.decrease);
    await tester.pumpAndSettle();
    expect(node().value, '4 of 5 stars');
    handle.dispose();
  });

  testWidgets('cannot go below 1 once rated', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIn(tester, const _Host(initial: 1));
    expect(
      tester.getSemantics(find.byType(StarRating)).getSemanticsData().hasAction(SemanticsAction.decrease),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('disabled: taps do nothing, no actions', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = <int>[];
    await pumpIn(tester, _Host(initial: 2, enabled: false, onChange: changes.add));
    await tester.tap(find.byKey(const ValueKey('star-5')));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    final data = tester.getSemantics(find.byType(StarRating)).getSemanticsData();
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    handle.dispose();
  });

  testWidgets('the chosen stars spring', (tester) async {
    await pumpIn(tester, const _Host());
    await tester.tap(find.byKey(const ValueKey('star-3')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('with reduced motion the stars just change', (tester) async {
    await pumpIn(tester, const _Host(), mode: LaneMode.saver);
    await tester.tap(find.byKey(const ValueKey('star-3')));
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Hindi value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIn(tester, const _Host(initial: 3), locale: const Locale('hi'));
    expect(tester.getSemantics(find.byType(StarRating)).value, '5 में से 3 स्टार');
    handle.dispose();
  });
}

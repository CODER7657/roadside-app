// #127: ChatBubble and ChatComposer (U11).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

Future<void> pumpIn(
  WidgetTester tester,
  Widget child, {
  LaneMode mode = LaneMode.day,
  Locale locale = const Locale('en'),
  double textScale = 1,
  Size size = const Size(360, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: LanePreview(mode: mode, locale: locale, textScale: textScale, child: child),
    ),
  );
  await tester.pump();
}

Widget _page(Widget child) => Scaffold(
  body: Padding(padding: const EdgeInsets.all(16), child: child),
);

void main() {
  group('ChatBubble', () {
    testWidgets('mine sits on the right, theirs on the left', (tester) async {
      await pumpIn(
        tester,
        _page(
          const Column(
            children: [
              ChatBubble(mine: false, text: 'theirs'),
              ChatBubble(mine: true, text: 'mine'),
            ],
          ),
        ),
      );
      final theirs = tester.getRect(find.text('theirs'));
      final mine = tester.getRect(find.text('mine'));
      expect(theirs.left, lessThan(60));
      expect(mine.right, greaterThan(300));
    });

    testWidgets('one TalkBack node per message, with the photo and the state', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpIn(
        tester,
        _page(
          const Column(
            children: [
              ChatBubble(
                mine: false,
                text: 'Near the pump',
                semanticLabel: 'Kiran: Near the pump',
                time: '10:02',
              ),
              ChatBubble(
                mine: true,
                text: 'On my way',
                image: SizedBox(width: 40, height: 30),
                delivery: ChatDelivery.sending,
              ),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Kiran: Near the pump'), findsOneWidget);
      expect(find.bySemanticsLabel('On my way, Photo'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('On my way, Photo'));
      expect(node.value, 'Sending…');
      semantics.dispose();
    });

    testWidgets('sending shows it; sent shows the time', (tester) async {
      await pumpIn(
        tester,
        _page(
          const Column(
            children: [
              ChatBubble(mine: true, text: 'a', time: '10:03'),
              ChatBubble(mine: true, text: 'b', time: '10:04', delivery: ChatDelivery.sending),
            ],
          ),
        ),
      );
      expect(find.text('10:03'), findsOneWidget);
      expect(find.text('10:04'), findsNothing);
      expect(find.text('Sending…'), findsOneWidget);
    });

    testWidgets('a failed message says so and retries on tap (48 dp target)', (tester) async {
      var retries = 0;
      await pumpIn(
        tester,
        _page(ChatBubble(mine: true, text: 'lost', delivery: ChatDelivery.failed, onRetry: () => retries++)),
      );
      expect(find.text('Not sent. Tap to try again.'), findsOneWidget);
      await tester.tap(find.text('lost'));
      expect(retries, 1);
      expect(tester.getSize(find.byType(GestureDetector).first).height, greaterThanOrEqualTo(48));
    });

    testWidgets("the other person's messages never show a delivery state", (tester) async {
      await pumpIn(tester, _page(const ChatBubble(mine: false, text: 'x', delivery: ChatDelivery.failed)));
      expect(find.text('Not sent. Tap to try again.'), findsNothing);
    });
  });

  group('ChatComposer', () {
    Future<(TextEditingController, List<String>)> pumpComposer(
      WidgetTester tester, {
      bool attach = true,
      bool enabled = true,
    }) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final sent = <String>[];
      await pumpIn(
        tester,
        _page(
          Align(
            alignment: Alignment.bottomCenter,
            child: ChatComposer(
              controller: controller,
              onSend: sent.add,
              onAttach: attach ? () {} : null,
              enabled: enabled,
            ),
          ),
        ),
      );
      return (controller, sent);
    }

    InkWell sendButton(WidgetTester tester) =>
        tester.widget<InkWell>(find.byKey(const ValueKey('chat-send')));

    testWidgets('send stays disabled until there is text (spaces only count as empty)', (tester) async {
      final (_, sent) = await pumpComposer(tester);
      expect(sendButton(tester).onTap, isNull);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(sendButton(tester).onTap, isNull);
      await tester.enterText(find.byType(TextField), '  Coming in 2 min  ');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await tester.pump();
      expect(sent, ['Coming in 2 min']);
    });

    testWidgets('sending clears the field', (tester) async {
      final (controller, _) = await pumpComposer(tester);
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(sendButton(tester).onTap, isNull);
    });

    testWidgets('text is capped at 500 characters; the count shows near the limit', (tester) async {
      final (controller, _) = await pumpComposer(tester);
      await tester.enterText(find.byType(TextField), 'a' * 449);
      await tester.pump();
      expect(find.textContaining('characters left'), findsNothing);
      await tester.enterText(find.byType(TextField), 'a' * 460);
      await tester.pump();
      expect(find.text('40 characters left'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'a' * 600);
      await tester.pump();
      expect(controller.text.length, 500);
      expect(find.text('0 characters left'), findsOneWidget);
    });

    testWidgets('the camera button only shows with onAttach; targets are 48 dp', (tester) async {
      await pumpComposer(tester, attach: false);
      expect(find.byTooltip('Add a photo'), findsNothing);
      await pumpComposer(tester);
      expect(find.byTooltip('Add a photo'), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('chat-send'))), const Size(48, 48));
      expect(tester.getSize(find.byTooltip('Add a photo')).height, greaterThanOrEqualTo(48));
    });

    testWidgets('disabled: nothing can be sent or attached', (tester) async {
      final (_, sent) = await pumpComposer(tester, enabled: false);
      expect(sendButton(tester).onTap, isNull);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
      expect(sent, isEmpty);
    });

    testWidgets('TalkBack: the send button is labelled and says when it is off', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpComposer(tester);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Send')),
        isSemantics(isButton: true, isEnabled: false),
      );
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Send')),
        isSemantics(isButton: true, isEnabled: true),
      );
      semantics.dispose();
    });
  });

  for (final mode in LaneMode.values) {
    testWidgets('the sample lays out in ${mode.name}', (tester) async {
      await pumpIn(tester, const LaneChatSample(), mode: mode);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('fits at 320 px, 200% text, Hindi and Gujarati', (tester) async {
    for (final (locale, theirs) in const [
      (Locale('hi'), 'मैं पेट्रोल पंप के पास हूँ।'),
      (Locale('gu'), 'હું પેટ્રોલ પંપ પાસે છું.'),
    ]) {
      await pumpIn(
        tester,
        LaneChatSample(theirs: theirs),
        locale: locale,
        textScale: 2,
        size: const Size(320, 800),
      );
      expect(tester.takeException(), isNull, reason: locale.languageCode);
    }
  });
}

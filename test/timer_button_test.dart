import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer_button/flutter_timer_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('TimerButton countdown', () {
    testWidgets('blocks taps while running and re-enables after duration', (
      tester,
    ) async {
      var pressCount = 0;
      await tester.pumpWidget(
        _wrap(
          TimerButton.countdown(
            duration: const Duration(milliseconds: 500),
            autoStart: false,
            onPressed: () => pressCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First tap: idle -> starts the timer and fires onPressed.
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(pressCount, 1);
      expect(find.textContaining('s left'), findsOneWidget);

      // Tap while running is blocked.
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(pressCount, 1);

      // Elapse past the duration.
      await tester.pump(const Duration(milliseconds: 550));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);

      // Now idle again, tap works.
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(pressCount, 2);
    });
  });

  group('TimerButton progress', () {
    testWidgets('label reflects setProgress value', (tester) async {
      final controller = TimerButtonController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          TimerButton(
            mode: TimerButtonMode.progress,
            controller: controller,
            labelBuilder: (context, remaining, progress, isRunning) {
              return Text(defaultProgressLabel(progress));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0%'), findsOneWidget);

      controller.setProgress(0.5);
      await tester.pumpAndSettle();
      expect(find.text('50%'), findsOneWidget);

      controller.setProgress(1.0);
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('TimerButton enabled', () {
    testWidgets(
        'enabled: false always blocks taps regardless of timer '
        'state', (tester) async {
      var pressCount = 0;
      final controller = TimerButtonController(
        duration: const Duration(milliseconds: 200),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          TimerButton(
            mode: TimerButtonMode.countdown,
            controller: controller,
            enabled: false,
            onPressed: () => pressCount++,
            child: const Text('Disabled'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      await tester.pump();
      expect(pressCount, 0);

      controller.start();
      await tester.pump();
      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      await tester.pump();
      expect(pressCount, 0);

      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      await tester.pump();
      expect(pressCount, 0);
    });
  });

  group('TimerButton autoStart', () {
    testWidgets('begins immediately after first frame', (tester) async {
      final controller = TimerButtonController(
        duration: const Duration(seconds: 2),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          TimerButton(
            mode: TimerButtonMode.countdown,
            controller: controller,
            autoStart: true,
          ),
        ),
      );

      expect(controller.isRunning, isTrue);
      controller.stop();
    });
  });
}

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer_button/flutter_timer_button.dart';

void main() {
  group('TimerButtonController', () {
    test('start begins ticking and decrements remaining', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        expect(controller.isRunning, isTrue);
        async.elapse(const Duration(milliseconds: 300));
        expect(controller.remaining, const Duration(milliseconds: 700));
        controller.dispose();
      });
    });

    test('pause stops ticking, resume continues from remaining', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        async.elapse(const Duration(milliseconds: 300));
        controller.pause();
        expect(controller.isRunning, isFalse);
        final remainingAfterPause = controller.remaining;
        async.elapse(const Duration(milliseconds: 300));
        expect(controller.remaining, remainingAfterPause);

        controller.resume();
        expect(controller.isRunning, isTrue);
        async.elapse(const Duration(milliseconds: 200));
        expect(controller.remaining, const Duration(milliseconds: 500));
        controller.dispose();
      });
    });

    test('resume is a no-op if already running', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        controller.resume();
        async.elapse(const Duration(milliseconds: 100));
        expect(controller.remaining, const Duration(milliseconds: 900));
        controller.dispose();
      });
    });

    test('resume is a no-op if remaining is zero', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(milliseconds: 100),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        async.elapse(const Duration(milliseconds: 100));
        expect(controller.remaining, Duration.zero);
        controller.resume();
        expect(controller.isRunning, isFalse);
        controller.dispose();
      });
    });

    test('stop cancels the timer without resetting remaining', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        async.elapse(const Duration(milliseconds: 300));
        controller.stop();
        expect(controller.isRunning, isFalse);
        expect(controller.remaining, const Duration(milliseconds: 700));
        controller.dispose();
      });
    });

    test('reset restores initial state', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        async.elapse(const Duration(milliseconds: 300));
        controller.setProgress(0.5);
        controller.reset();
        expect(controller.isRunning, isFalse);
        expect(controller.remaining, const Duration(seconds: 1));
        expect(controller.isCompleted, isFalse);
        expect(controller.progress, 0);
        controller.dispose();
      });
    });

    test('elapsedFraction and remainingFraction math', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        async.elapse(const Duration(milliseconds: 400));
        expect(controller.elapsedFraction, closeTo(0.4, 0.001));
        expect(controller.remainingFraction, closeTo(0.6, 0.001));
        controller.dispose();
      });
    });

    test('elapsedFraction guards duration of zero', () {
      final controller = TimerButtonController(duration: Duration.zero);
      expect(controller.elapsedFraction, 0);
      controller.dispose();
    });

    test('starting with duration zero completes immediately', () {
      var completedCount = 0;
      final controller = TimerButtonController();
      controller.attach(onCompleted: () => completedCount++);
      controller.start(Duration.zero);
      expect(controller.isCompleted, isTrue);
      expect(completedCount, 1);
      controller.dispose();
    });

    test('setProgress clamps to 0-1', () {
      final controller = TimerButtonController();
      controller.setProgress(-0.5);
      expect(controller.progress, 0);
      controller.setProgress(1.5);
      expect(controller.progress, 1);
      controller.dispose();
    });

    test('setProgress cancels a running timer', () {
      fakeAsync((async) {
        final controller = TimerButtonController(
          duration: const Duration(seconds: 1),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.start();
        controller.setProgress(0.5);
        expect(controller.isRunning, isFalse);
        expect(controller.progress, 0.5);
        controller.dispose();
      });
    });

    test('setProgress fires onCompleted exactly once at 1.0', () {
      var completedCount = 0;
      final controller = TimerButtonController();
      controller.attach(onCompleted: () => completedCount++);
      controller.setProgress(0.5);
      controller.setProgress(1.0);
      expect(completedCount, 1);
      controller.setProgress(1.0);
      expect(completedCount, 1);
      controller.dispose();
    });

    test('timer completion fires onCompleted and onTick', () {
      fakeAsync((async) {
        var completedCount = 0;
        Duration? lastTick;
        final controller = TimerButtonController(
          duration: const Duration(milliseconds: 200),
          tickInterval: const Duration(milliseconds: 100),
        );
        controller.attach(
          onCompleted: () => completedCount++,
          onTick: (remaining) => lastTick = remaining,
        );
        controller.start();
        async.elapse(const Duration(milliseconds: 200));
        expect(completedCount, 1);
        expect(controller.isCompleted, isTrue);
        expect(lastTick, Duration.zero);
        controller.dispose();
      });
    });
  });
}

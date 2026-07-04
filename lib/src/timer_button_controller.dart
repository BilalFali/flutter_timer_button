import 'dart:async';

import 'package:flutter/foundation.dart';

/// Drives the countdown/progress state behind a [TimerButton].
///
/// Can be created and owned by the widget itself, or instantiated
/// externally to observe/drive the timer from outside the button (e.g. to
/// call [setProgress] from a network callback).
class TimerButtonController extends ChangeNotifier {
  TimerButtonController({
    this.duration = const Duration(seconds: 5),
    this.tickInterval = const Duration(milliseconds: 50),
  }) : _remaining = duration;

  /// The total duration of a countdown run.
  Duration duration;

  /// How often the internal timer decrements [remaining].
  final Duration tickInterval;

  Timer? _timer;
  Duration _remaining;
  double? _manualProgress;
  bool _isCompleted = false;

  VoidCallback? _onCompleted;
  ValueChanged<Duration>? _onTick;

  /// Time left in the current countdown run.
  Duration get remaining => _remaining;

  /// Whether the internal timer is currently ticking.
  bool get isRunning => _timer?.isActive ?? false;

  /// Whether the countdown/progress run has completed.
  bool get isCompleted => _isCompleted;

  /// Fraction of [duration] that has elapsed, clamped to 0-1.
  ///
  /// Returns 0 when [duration] is zero.
  double get elapsedFraction {
    if (duration.inMicroseconds <= 0) return 0;
    final elapsed = duration - _remaining;
    return (elapsed.inMicroseconds / duration.inMicroseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  /// The inverse of [elapsedFraction].
  double get remainingFraction => 1 - elapsedFraction;

  /// The current progress value, 0-1.
  ///
  /// Returns the manually set value from [setProgress] if one has been set,
  /// otherwise falls back to [elapsedFraction].
  double get progress => _manualProgress ?? elapsedFraction;

  /// Wires widget-level callbacks into this controller.
  void attach({VoidCallback? onCompleted, ValueChanged<Duration>? onTick}) {
    _onCompleted = onCompleted;
    _onTick = onTick;
  }

  /// Resets and begins ticking down from [newDuration] (or [duration]).
  void start([Duration? newDuration]) {
    _timer?.cancel();
    _manualProgress = null;
    _isCompleted = false;
    if (newDuration != null) {
      duration = newDuration;
    }
    _remaining = duration;
    notifyListeners();

    if (duration.inMicroseconds <= 0) {
      _isCompleted = true;
      notifyListeners();
      _onCompleted?.call();
      return;
    }

    _timer = Timer.periodic(tickInterval, _onTimerTick);
  }

  void _onTimerTick(Timer timer) {
    final next = _remaining - tickInterval;
    if (next <= Duration.zero) {
      _remaining = Duration.zero;
      timer.cancel();
      _isCompleted = true;
      notifyListeners();
      _onTick?.call(_remaining);
      _onCompleted?.call();
      return;
    }
    _remaining = next;
    notifyListeners();
    _onTick?.call(_remaining);
  }

  /// Pauses the countdown without resetting [remaining].
  void pause() {
    _timer?.cancel();
    notifyListeners();
  }

  /// Resumes ticking from the current [remaining].
  ///
  /// No-op if already running or if [remaining] is already zero.
  void resume() {
    if (isRunning || _remaining <= Duration.zero) return;
    _timer = Timer.periodic(tickInterval, _onTimerTick);
    notifyListeners();
  }

  /// Cancels the timer without resetting [remaining].
  void stop() {
    _timer?.cancel();
    notifyListeners();
  }

  /// Cancels the timer and resets [remaining]/[progress] to their initial
  /// state.
  void reset() {
    _timer?.cancel();
    _remaining = duration;
    _manualProgress = null;
    _isCompleted = false;
    notifyListeners();
  }

  /// Manually sets [progress], cancelling any running timer.
  ///
  /// Clamped to 0-1. Sets [isCompleted] and fires the completion callback
  /// exactly once when [value] reaches 1.0.
  void setProgress(double value) {
    _timer?.cancel();
    final clamped = value.clamp(0.0, 1.0);
    _manualProgress = clamped;
    final wasCompleted = _isCompleted;
    _isCompleted = clamped == 1.0;
    notifyListeners();
    if (_isCompleted && !wasCompleted) {
      _onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

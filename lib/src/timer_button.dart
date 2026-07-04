import 'package:flutter/material.dart';

import 'timer_button_controller.dart';
import 'timer_button_style.dart';

/// Whether a [TimerButton] counts down a fixed [Duration] or displays a
/// manually driven progress value.
enum TimerButtonMode { countdown, progress }

/// Default label for [TimerButtonMode.countdown]: "12s left".
String defaultCountdownLabel(Duration remaining) {
  final seconds = (remaining.inMilliseconds / 1000).ceil();
  return '${seconds}s left';
}

/// Default label for [TimerButtonMode.progress]: "42%".
String defaultProgressLabel(double progress) {
  return '${(progress * 100).round()}%';
}

/// A button that displays an animated fill indicator representing either a
/// countdown or a manually driven progress value.
///
/// Common uses: OTP resend cooldowns, rate-limited actions, and
/// sync/upload/download progress indication.
class TimerButton extends StatefulWidget {
  const TimerButton({
    super.key,
    required this.mode,
    this.duration = const Duration(seconds: 5),
    this.controller,
    this.onPressed,
    this.onCompleted,
    this.onTick,
    this.labelBuilder,
    this.child,
    this.leading,
    this.trailing,
    this.autoStart = false,
    this.disableWhileRunning = true,
    this.enabled = true,
    this.style = const TimerButtonStyle(),
    this.restartOnPressWhenIdle = true,
  });

  /// Whether this button counts down a duration or shows manual progress.
  final TimerButtonMode mode;

  /// The countdown duration, used when [controller] is null or when the
  /// button (re)starts.
  final Duration duration;

  /// Controls the timer/progress state. If null, a controller is created
  /// and owned internally.
  final TimerButtonController? controller;

  /// Called when the button is tapped and not blocked.
  final VoidCallback? onPressed;

  /// Called when the countdown/progress run completes.
  final VoidCallback? onCompleted;

  /// Called on every timer tick with the remaining duration.
  final ValueChanged<Duration>? onTick;

  /// Builds the button's label from the current remaining/progress state.
  final Widget Function(
    BuildContext context,
    Duration remaining,
    double progress,
    bool isRunning,
  )? labelBuilder;

  /// If provided, replaces [labelBuilder] entirely.
  final Widget? child;

  /// Optional widget shown before the label.
  final Widget? leading;

  /// Optional widget shown after the label.
  final Widget? trailing;

  /// Whether to start the timer automatically on the first frame.
  final bool autoStart;

  /// Whether taps are blocked while the timer is running.
  final bool disableWhileRunning;

  /// Whether the button responds to input at all.
  final bool enabled;

  /// Visual configuration.
  final TimerButtonStyle style;

  /// If true, tapping while idle both calls [onPressed] and restarts the
  /// timer.
  final bool restartOnPressWhenIdle;

  /// Creates a countdown-mode button, e.g. for OTP resend flows.
  ///
  /// Shows [idleChild] (default "Start") while idle, otherwise the resolved
  /// [labelBuilder] result or [defaultCountdownLabel].
  factory TimerButton.countdown({
    Key? key,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onPressed,
    VoidCallback? onCompleted,
    ValueChanged<Duration>? onTick,
    String Function(Duration remaining)? labelBuilder,
    Widget? idleChild,
    Widget? leading,
    bool autoStart = true,
    TimerButtonController? controller,
    TimerButtonStyle style = const TimerButtonStyle(),
  }) {
    return TimerButton(
      key: key,
      mode: TimerButtonMode.countdown,
      duration: duration,
      controller: controller,
      onPressed: onPressed,
      onCompleted: onCompleted,
      onTick: onTick,
      leading: leading,
      autoStart: autoStart,
      style: style,
      labelBuilder: (context, remaining, progress, isRunning) {
        if (!isRunning) {
          return idleChild ?? const Text('Start');
        }
        final text = labelBuilder != null
            ? labelBuilder(remaining)
            : defaultCountdownLabel(remaining);
        return Text(text);
      },
    );
  }

  /// Creates a progress-mode button, e.g. for sync/upload/download
  /// indication driven via [TimerButtonController.setProgress].
  factory TimerButton.progress({
    Key? key,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onPressed,
    VoidCallback? onCompleted,
    String Function(double progress)? labelBuilder,
    Widget? leading,
    bool autoStart = true,
    bool disableWhileRunning = false,
    TimerButtonController? controller,
    TimerButtonStyle style = const TimerButtonStyle(),
  }) {
    return TimerButton(
      key: key,
      mode: TimerButtonMode.progress,
      duration: duration,
      controller: controller,
      onPressed: onPressed,
      onCompleted: onCompleted,
      leading: leading,
      autoStart: autoStart,
      disableWhileRunning: disableWhileRunning,
      style: style,
      labelBuilder: (context, remaining, progress, isRunning) {
        final text = labelBuilder != null
            ? labelBuilder(progress)
            : defaultProgressLabel(progress);
        return Text(text);
      },
    );
  }

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  TimerButtonController? _ownedController;

  TimerButtonController get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    _initController();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.start(widget.duration);
        }
      });
    }
  }

  void _initController() {
    if (widget.controller == null) {
      _ownedController = TimerButtonController(duration: widget.duration);
    }
    _controller.attach(
      onCompleted: widget.onCompleted,
      onTick: widget.onTick,
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant TimerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (oldWidget.controller == null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      _initController();
    } else {
      _controller.attach(
        onCompleted: widget.onCompleted,
        onTick: widget.onTick,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    final running = _controller.isRunning;
    if (widget.disableWhileRunning && running) return;

    widget.onPressed?.call();

    if (widget.restartOnPressWhenIdle && !running) {
      _controller.start(widget.duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final running = _controller.isRunning;
    final blocked = !widget.enabled || (widget.disableWhileRunning && running);

    final fraction = widget.mode == TimerButtonMode.countdown
        ? _controller.elapsedFraction
        : _controller.progress;

    final foreground =
        widget.enabled ? style.foregroundColor : style.disabledForegroundColor;

    final content = widget.child ??
        widget.labelBuilder?.call(
          context,
          _controller.remaining,
          _controller.progress,
          running,
        ) ??
        const SizedBox.shrink();

    return SizedBox(
      height: style.height,
      child: ClipRRect(
        borderRadius: style.borderRadius,
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              color: widget.enabled
                  ? style.backgroundColor
                  : style.disabledBackgroundColor,
              border: style.border,
            ),
            child: InkWell(
              onTap: blocked ? null : _handleTap,
              splashColor: style.rippleColor,
              highlightColor: style.rippleColor,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: style.minWidth),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (style.showFill && widget.enabled)
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: fraction),
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.linear,
                          builder: (context, value, child) {
                            return FractionallySizedBox(
                              widthFactor: value,
                              alignment: Alignment.centerLeft,
                              child: ColoredBox(color: style.fillColor),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: style.padding,
                      child: Center(
                        child: DefaultTextStyle.merge(
                          style: (style.textStyle ?? const TextStyle())
                              .copyWith(color: foreground),
                          child: IconTheme.merge(
                            data: IconThemeData(color: foreground),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.leading != null) ...[
                                  widget.leading!,
                                  const SizedBox(width: 8),
                                ],
                                Flexible(child: content),
                                if (widget.trailing != null) ...[
                                  const SizedBox(width: 8),
                                  widget.trailing!,
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

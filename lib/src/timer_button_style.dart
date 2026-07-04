import 'package:flutter/material.dart';

/// Visual configuration for a [TimerButton].
@immutable
class TimerButtonStyle {
  const TimerButtonStyle({
    this.backgroundColor = const Color(0xFF3D5AFE),
    this.fillColor = const Color(0xFF7C97FF),
    this.foregroundColor = Colors.white,
    this.disabledBackgroundColor = const Color(0xFF12172A),
    this.disabledForegroundColor = const Color(0xFF6C7280),
    this.height = 52,
    this.minWidth = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.textStyle,
    this.border,
    this.showFill = true,
    this.rippleColor,
  });

  /// The base background color of the button.
  final Color backgroundColor;

  /// The color that animates in from the left, representing progress or
  /// elapsed time.
  final Color fillColor;

  /// The color used for text and icon content.
  final Color foregroundColor;

  /// Background color used when the button is disabled.
  final Color disabledBackgroundColor;

  /// Foreground color used when the button is disabled.
  final Color disabledForegroundColor;

  /// The fixed height of the button.
  final double height;

  /// The minimum width of the button.
  final double minWidth;

  /// The corner radius applied to the button.
  final BorderRadius borderRadius;

  /// The padding around the button's content.
  final EdgeInsetsGeometry padding;

  /// Optional override for the label's [TextStyle].
  final TextStyle? textStyle;

  /// Optional border drawn around the button.
  final BoxBorder? border;

  /// Whether to render the animated fill indicator.
  final bool showFill;

  /// Optional override for the ink ripple color.
  final Color? rippleColor;

  /// A solid, filled button style.
  ///
  /// [fillColor] defaults to [color] lightened 35% toward white.
  factory TimerButtonStyle.filled({
    required Color color,
    Color? fillColor,
    Color foregroundColor = Colors.white,
  }) {
    return TimerButtonStyle(
      backgroundColor: color,
      fillColor: fillColor ?? Color.lerp(color, Colors.white, 0.35)!,
      foregroundColor: foregroundColor,
    );
  }

  /// An outlined button style with a transparent background.
  factory TimerButtonStyle.outlined({
    required Color color,
    Color? backgroundTint,
  }) {
    return TimerButtonStyle(
      backgroundColor: Colors.transparent,
      // ignore: deprecated_member_use
      fillColor: backgroundTint ?? color.withOpacity(0.12),
      foregroundColor: color,
      // ignore: deprecated_member_use
      border: Border.all(color: color.withOpacity(0.6)),
    );
  }

  /// A dark themed button style.
  factory TimerButtonStyle.dark({
    Color base = const Color(0xFF0F1626),
    Color fill = const Color(0xFF3D4C74),
    Color foreground = Colors.white,
  }) {
    return TimerButtonStyle(
      backgroundColor: base,
      fillColor: fill,
      foregroundColor: foreground,
    );
  }

  /// Returns a copy of this style with the given fields replaced.
  TimerButtonStyle copyWith({
    Color? backgroundColor,
    Color? fillColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    double? height,
    double? minWidth,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    BoxBorder? border,
    bool? showFill,
    Color? rippleColor,
  }) {
    return TimerButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fillColor: fillColor ?? this.fillColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      border: border ?? this.border,
      showFill: showFill ?? this.showFill,
      rippleColor: rippleColor ?? this.rippleColor,
    );
  }
}

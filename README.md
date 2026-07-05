# flutter_timer_button

A highly customizable timed & progress button for Flutter with an animated
fill indicator. Built for OTP resend cooldowns, rate-limited actions, and
sync/upload/download progress.

![demo](https://raw.githubusercontent.com/BilalFali/flutter_timer_button/main/ezgif-10542e8774d88eeb.gif)

## Why

Most "timer button" packages only disable the button and show a countdown
label. `flutter_timer_button` also animates a fill indicator across the
button, so users can *see* progress or elapsed time, not just read it:

| | disable-only timer buttons | `flutter_timer_button` |
| --- | --- | --- |
| Countdown label | ✅ | ✅ |
| Disables while running | ✅ | ✅ |
| Animated fill indicator | ❌ | ✅ |
| Manual progress mode (sync/upload/download) | ❌ | ✅ |
| Fully styleable (filled/outlined/dark) | varies | ✅ |

## Install

```yaml
dependencies:
  flutter_timer_button: ^0.1.0
```

## Usage

### Countdown (e.g. OTP resend)

```dart
import 'package:flutter_timer_button/flutter_timer_button.dart';

TimerButton.countdown(
  duration: const Duration(seconds: 30),
  idleChild: const Text('Send code'),
  onPressed: () => sendOtp(),
  style: TimerButtonStyle.filled(color: Colors.teal),
)
```

Tapping while idle calls `onPressed` and starts the cooldown; the button
disables itself and shows "Resend in Ns" (via the default or a custom
`labelBuilder`) until it completes.

### Progress (e.g. upload/sync)

```dart
final controller = TimerButtonController();

TimerButton.progress(
  controller: controller,
  onPressed: () async {
    for (var i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      controller.setProgress(i / 100);
    }
  },
  style: TimerButtonStyle.filled(color: Colors.orange),
)
```

Drive `controller.setProgress(value)` from anywhere — a network callback,
a stream listener, an isolate — and the fill indicator animates to match.

## API reference

### `TimerButton`

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `TimerButtonMode` | required | `countdown` or `progress`. |
| `duration` | `Duration` | `5s` | Countdown length / progress-run duration. |
| `controller` | `TimerButtonController?` | `null` | Owned internally if omitted. |
| `onPressed` | `VoidCallback?` | `null` | Called on an unblocked tap. |
| `onCompleted` | `VoidCallback?` | `null` | Called once the run finishes. |
| `onTick` | `ValueChanged<Duration>?` | `null` | Called every timer tick. |
| `labelBuilder` | `Widget Function(context, remaining, progress, isRunning)?` | `null` | Custom label. |
| `child` | `Widget?` | `null` | Overrides `labelBuilder` entirely. |
| `leading` / `trailing` | `Widget?` | `null` | Optional icons/avatars around the label. |
| `autoStart` | `bool` | `false` | Start on first frame. |
| `disableWhileRunning` | `bool` | `true` | Block taps while running. |
| `enabled` | `bool` | `true` | Master enable/disable switch. |
| `style` | `TimerButtonStyle` | `TimerButtonStyle()` | Visual configuration. |
| `restartOnPressWhenIdle` | `bool` | `true` | Tapping while idle restarts the timer. |

### `TimerButton.countdown(...)` / `TimerButton.progress(...)`

Convenience factories pre-wiring sensible defaults and label formatting for
each mode (see Usage above).

### `TimerButtonController`

| Member | Description |
| --- | --- |
| `duration` / `remaining` | Configured length / time left. |
| `isRunning` / `isCompleted` | Current run state. |
| `elapsedFraction` / `remainingFraction` | 0–1 countdown progress. |
| `progress` | Manual value from `setProgress`, else `elapsedFraction`. |
| `attach({onCompleted, onTick})` | Wires widget callbacks in. |
| `start([newDuration])` | Resets and begins ticking. |
| `pause()` / `resume()` / `stop()` / `reset()` | Playback controls. |
| `setProgress(value)` | Manually drive progress, cancelling any timer. |

### `TimerButtonStyle`

| Member | Description |
| --- | --- |
| `TimerButtonStyle.filled({color, fillColor, foregroundColor})` | Solid button, fill defaults to `color` lightened 35%. |
| `TimerButtonStyle.outlined({color, backgroundTint})` | Transparent background with a colored border. |
| `TimerButtonStyle.dark({base, fill, foreground})` | Dark themed variant. |
| `copyWith(...)` | Override any individual field. |

## Additional information

Contributions and issues are welcome on the project's GitHub repository.

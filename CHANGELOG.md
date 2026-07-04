## 0.1.0

Initial release.

- `TimerButton` widget with `countdown` and `progress` modes, plus
  `TimerButton.countdown` and `TimerButton.progress` convenience factories.
- `TimerButtonController` (`ChangeNotifier`) driving elapsed/remaining
  fractions, manual `setProgress`, start/pause/resume/stop/reset.
- Animated fill indicator representing elapsed time or progress.
- `TimerButtonStyle` with `filled`, `outlined`, and `dark` factory
  constructors, plus full manual customization via `copyWith`.
- Configurable `leading`/`trailing` widgets, custom label builders, and a
  fully custom `child` override.
- `autoStart`, `disableWhileRunning`, `restartOnPressWhenIdle`, and `enabled`
  behavior flags.
- Example app showcasing OTP resend, countdowns, and sync/download progress
  patterns.

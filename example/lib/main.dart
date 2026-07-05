import 'package:flutter/material.dart';
import 'package:flutter_timer_button/flutter_timer_button.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterTimerButton',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ShowcasePage(),
    );
  }
}

const _blue = Color(0xFF3D5AFE);
const _teal = Color(0xFF00BFA5);
const _orange = Color(0xFFFF8F00);

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final _syncController = TimerButtonController();
  final _downloadingController = TimerButtonController();
  final _continuingController = TimerButtonController()..setProgress(0.29);
  final _blue42Controller = TimerButtonController()..setProgress(0.42);
  final _outlined38Controller = TimerButtonController()..setProgress(0.38);
  final _teal34Controller = TimerButtonController()..setProgress(0.34);

  final _tealCountdownController = TimerButtonController(
    duration: const Duration(seconds: 4),
  );
  final _blueCountdownController = TimerButtonController(
    duration: const Duration(seconds: 3),
  );
  final _darkCountdownController = TimerButtonController(
    duration: const Duration(seconds: 2),
  );
  final _otpController = TimerButtonController(
    duration: const Duration(seconds: 5),
  );
  final _downloadController = TimerButtonController(
    duration: const Duration(seconds: 6),
  );

  Future<void> _fakeProgress(TimerButtonController controller) async {
    controller.setProgress(0);
    const steps = 24;
    const stepDuration = Duration(milliseconds: 100); // ~2.4s total
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(stepDuration);
      if (!mounted) return;
      controller.setProgress(i / steps);
    }
  }

  @override
  void dispose() {
    _syncController.dispose();
    _downloadingController.dispose();
    _continuingController.dispose();
    _blue42Controller.dispose();
    _outlined38Controller.dispose();
    _teal34Controller.dispose();
    _tealCountdownController.dispose();
    _blueCountdownController.dispose();
    _darkCountdownController.dispose();
    _otpController.dispose();
    _downloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'TimerButton',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'A timed & progress button with an animated fill indicator.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            const _SectionTitle('Showcase'),
            const SizedBox(height: 16),

            // Blue progress button "Continuing 29%"
            TimerButton(
              mode: TimerButtonMode.progress,
              controller: _continuingController,
              style: TimerButtonStyle.filled(color: _blue),
              labelBuilder: (context, remaining, progress, isRunning) {
                return Text('Continuing ${(progress * 100).round()}%');
              },
            ),
            const SizedBox(height: 12),

            // Teal countdown button "4s left"
            TimerButton.countdown(
              duration: const Duration(seconds: 4),
              controller: _tealCountdownController,
              autoStart: true,
              style: TimerButtonStyle.filled(color: _teal),
            ),
            const SizedBox(height: 12),

            // Orange progress button "Sync 40%" - fake async progress on tap
            TimerButton(
              mode: TimerButtonMode.progress,
              controller: _syncController,
              disableWhileRunning: false,
              style: TimerButtonStyle.filled(color: _orange),
              onPressed: () => _fakeProgress(_syncController),
              labelBuilder: (context, remaining, progress, isRunning) {
                return Text('Sync ${(progress * 100).round()}%');
              },
            ),
            const SizedBox(height: 12),

            // Dark progress button "Downloading 26%" with CircleAvatar leading
            TimerButton(
              mode: TimerButtonMode.progress,
              controller: _downloadingController,
              disableWhileRunning: false,
              style: TimerButtonStyle.dark(),
              leading: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white24,
                child: Text('D', style: TextStyle(fontSize: 11)),
              ),
              onPressed: () => _fakeProgress(_downloadingController),
              labelBuilder: (context, remaining, progress, isRunning) {
                return Text('Downloading ${(progress * 100).round()}%');
              },
            ),
            const SizedBox(height: 12),

            // Row: filled blue "42%" and outlined blue "38%"
            Row(
              children: [
                Expanded(
                  child: TimerButton(
                    mode: TimerButtonMode.progress,
                    controller: _blue42Controller,
                    style: TimerButtonStyle.filled(color: _blue),
                    labelBuilder: (context, remaining, progress, isRunning) {
                      return Text(defaultProgressLabel(progress));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimerButton(
                    mode: TimerButtonMode.progress,
                    controller: _outlined38Controller,
                    style: TimerButtonStyle.outlined(color: _blue),
                    labelBuilder: (context, remaining, progress, isRunning) {
                      return Text(defaultProgressLabel(progress));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Small teal progress button "34%"
            TimerButton(
              mode: TimerButtonMode.progress,
              controller: _teal34Controller,
              style: TimerButtonStyle.filled(
                color: _teal,
              ).copyWith(height: 44),
              labelBuilder: (context, remaining, progress, isRunning) {
                return Text(defaultProgressLabel(progress));
              },
            ),

            const SizedBox(height: 32),
            const _SectionTitle('Basic, Auto-start, OTP, Download'),
            const SizedBox(height: 16),

            // Row: blue countdown "3s left" + dark countdown "2s left"
            Row(
              children: [
                Expanded(
                  child: TimerButton.countdown(
                    duration: const Duration(seconds: 3),
                    controller: _blueCountdownController,
                    autoStart: true,
                    style: TimerButtonStyle.filled(color: _blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimerButton.countdown(
                    duration: const Duration(seconds: 2),
                    controller: _darkCountdownController,
                    autoStart: true,
                    style: TimerButtonStyle.dark(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dark countdown button, enabled: false
            TimerButton(
              mode: TimerButtonMode.countdown,
              duration: const Duration(seconds: 5),
              autoStart: false,
              enabled: false,
              style: TimerButtonStyle.dark(),
              child: const Text('Disabled'),
            ),
            const SizedBox(height: 12),

            // Teal countdown "Resend in 5s" with idleChild "Send code"
            TimerButton.countdown(
              duration: const Duration(seconds: 5),
              controller: _otpController,
              autoStart: false,
              style: TimerButtonStyle.filled(color: _teal),
              idleChild: const Text('Send code'),
              labelBuilder: (remaining) {
                final seconds = (remaining.inMilliseconds / 1000).ceil();
                return 'Resend in ${seconds}s';
              },
            ),
            const SizedBox(height: 12),

            // Dark progress button "Download 42%" with download icon, autoStart over 6s
            TimerButton.progress(
              duration: const Duration(seconds: 6),
              controller: _downloadController,
              autoStart: true,
              style: TimerButtonStyle.dark(),
              leading: const Icon(Icons.download, size: 18),
              labelBuilder: (progress) =>
                  'Download ${(progress * 100).round()}%',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}

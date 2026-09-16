import 'package:flutter/material.dart';
import 'autonomous/gesture_camera_page.dart';

/// Autonomous mounting control screen. This is the one page that's actually
/// wired up: it opens the live gesture-recognition camera feed you already
/// got working natively.
class AutonomousControlPage extends StatelessWidget {
  const AutonomousControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.front_hand, size: 72),
          const SizedBox(height: 12),
          const Text(
            'Autonomous Mounting Control',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'The rover reads hand gestures from its onboard camera and uses '
            'them to steer the mount. Start the live feed below to see gesture '
            'recognition running.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GestureCameraPage()),
              );
            },
            icon: const Icon(Icons.videocam),
            label: const Text('Open Gesture Camera Feed'),
          ),
        ],
      ),
    );
  }
}

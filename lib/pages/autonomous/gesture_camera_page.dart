import 'package:flutter/material.dart';
import '../widgets/gesture_camera_view.dart';

/// Full-screen live feed: native camera preview + MediaPipe gesture
/// recognition, with the recognized gesture/confidence overlaid at the
/// bottom. This is the page reached from Autonomous Mounting Control.
class GestureCameraPage extends StatefulWidget {
  const GestureCameraPage({super.key});

  @override
  State<GestureCameraPage> createState() => _GestureCameraPageState();
}

class _GestureCameraPageState extends State<GestureCameraPage> {
  String _gesture = '—';
  double _confidence = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture Camera Feed')),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureCameraView(
              onGestureResult: (gesture, confidence) {
                setState(() {
                  _gesture = gesture;
                  _confidence = confidence;
                });
              },
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _gesture,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(_confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

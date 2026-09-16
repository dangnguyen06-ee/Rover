import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the native `gesture_camera_view` platform view (camera preview +
/// on-device MediaPipe gesture recognition) and listens to the
/// `gesture_camera_events` EventChannel it streams results on.
///
/// This is just the Flutter-side plumbing for the native code you already
/// have working (GestureCameraView.kt / GestureCameraViewFactory.kt /
/// MainActivity.kt) — nothing about the native side needs to change.
class GestureCameraView extends StatefulWidget {
  final void Function(String gesture, double confidence)? onGestureResult;

  const GestureCameraView({super.key, this.onGestureResult});

  @override
  State<GestureCameraView> createState() => _GestureCameraViewState();
}

class _GestureCameraViewState extends State<GestureCameraView> {
  static const _viewType = 'gesture_camera_view';
  static const _eventChannel = EventChannel('gesture_camera_events');

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final gesture = event['gesture']?.toString() ?? 'None';
          final confidence = (event['confidence'] as num?)?.toDouble() ?? 0.0;
          widget.onGestureResult?.call(gesture, confidence);
        }
      },
      onError: (Object error) {
        debugPrint('gesture_camera_events error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The native platform view only exists on Android right now (see
    // android/app/.../GestureCameraView.kt).
    return const AndroidView(
      viewType: _viewType,
      creationParams: <String, dynamic>{},
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}

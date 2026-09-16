// This file goes at:  android/app/src/main/kotlin/com/example/vision_sandbox/MainActivity.kt
// Replace the entire contents of your existing MainActivity.kt with this.

package com.example.vision_sandbox

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    // Holds the current "pipe" to Flutter for streaming gesture results.
    // The view factory below reads this via a lambda, so the platform view
    // always has an up-to-date sink even if Flutter reconnects the channel.
    private var gestureEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Request camera permission up front. This is a simple one-shot
        // request suitable for testing — a polished app would handle the
        // "denied" callback gracefully, but for now: if the system prompt
        // appears, tap Allow before opening the gesture test screen.
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 100)
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "gesture_camera_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    gestureEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    gestureEventSink = null
                }
            })

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "gesture_camera_view",
            GestureCameraViewFactory { gestureEventSink }
        )
    }
}

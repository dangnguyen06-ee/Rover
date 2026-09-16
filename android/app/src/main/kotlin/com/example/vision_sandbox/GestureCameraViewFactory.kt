// This file goes at:
// android/app/src/main/kotlin/com/example/vision_sandbox/GestureCameraViewFactory.kt

package com.example.vision_sandbox

import android.content.Context
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Tells Flutter how to create a GestureCameraView whenever the Dart side
 * asks for one (via the AndroidView widget with viewType "gesture_camera_view").
 */
class GestureCameraViewFactory(
    private val eventSinkProvider: () -> EventChannel.EventSink?
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return GestureCameraView(context, eventSinkProvider)
    }
}

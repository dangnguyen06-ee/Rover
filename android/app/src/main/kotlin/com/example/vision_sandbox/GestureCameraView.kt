// This file goes at:
// android/app/src/main/kotlin/com/example/vision_sandbox/GestureCameraView.kt
//
// (If your package name isn't com.example.vision_sandbox, put it in the
// matching folder path and update the "package" line below to match.)

package com.example.vision_sandbox

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.ImageProcessingOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizerResult
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executors

/**
 * A tiny standalone LifecycleOwner we manage ourselves. CameraX needs one to
 * know when to start/stop the camera, but a Flutter platform view doesn't
 * get one handed to it automatically the way a normal Activity screen does.
 */
private class SimpleLifecycleOwner : LifecycleOwner {
    val registry = LifecycleRegistry(this)
    override val lifecycle: Lifecycle get() = registry
}

/**
 * Shows a live camera preview AND runs MediaPipe's Gesture Recognizer on
 * every frame, in native Android code. Only the recognized gesture name and
 * confidence score are sent to Flutter — never the raw camera frames, which
 * keeps this fast and keeps the Dart side simple.
 */
class GestureCameraView(
    private val context: Context,
    private val eventSinkProvider: () -> EventChannel.EventSink?
) : PlatformView {

    private val container = FrameLayout(context)
    private val previewView = PreviewView(context)
    private val lifecycleOwner = SimpleLifecycleOwner()
    private val analysisExecutor = Executors.newSingleThreadExecutor()

    private var gestureRecognizer: GestureRecognizer? = null

    init {
        // PreviewView defaults to a SurfaceView-based rendering mode, which
        // doesn't composite correctly inside a Flutter AndroidView (renders
        // black). COMPATIBLE mode uses a TextureView instead, which Flutter
        // can actually draw — this is the fix for that exact symptom.
        previewView.implementationMode = PreviewView.ImplementationMode.COMPATIBLE

        container.addView(
            previewView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        lifecycleOwner.registry.currentState = Lifecycle.State.CREATED
        lifecycleOwner.registry.currentState = Lifecycle.State.STARTED
        lifecycleOwner.registry.currentState = Lifecycle.State.RESUMED

        setupGestureRecognizer()
        setupCamera()
    }

    private fun setupGestureRecognizer() {
        try {
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("gesture_recognizer.task")
                // Force CPU instead of the default GPU delegate. MediaPipe's
                // GPU delegate has a well-known native crash
                // (SIGSEGV inside libmediapipe_tasks_jni.so) on a range of
                // Android devices — this is very likely what you just hit.
                // CPU is a little slower per frame but far more stable,
                // which matters more while we're testing reliability.
                .setDelegate(Delegate.CPU)
                .build()

            val options = GestureRecognizer.GestureRecognizerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setNumHands(1)
                .setMinHandDetectionConfidence(0.5f)
                .setMinTrackingConfidence(0.5f)
                .setMinHandPresenceConfidence(0.5f)
                .setResultListener(::onGestureResult)
                .setErrorListener { e -> Log.e(TAG, "MediaPipe error", e) }
                .build()

            gestureRecognizer = GestureRecognizer.createFromOptions(context, options)
        } catch (e: Exception) {
            // Most common cause if this throws: gesture_recognizer.task isn't
            // in android/app/src/main/assets/ — see MODEL_SETUP.txt.
            Log.e(TAG, "Failed to set up GestureRecognizer", e)
        }
    }

    private fun setupCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

            val imageAnalysis = ImageAnalysis.Builder()
                // Ask CameraX to hand us already-decoded RGBA frames instead
                // of raw YUV, so we don't have to write our own color
                // conversion math.
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                // Always process the newest frame, drop older ones we
                // haven't gotten to yet — keeps latency low if the model
                // runs a bit slower than the camera's frame rate.
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()
                .also {
                    it.setAnalyzer(analysisExecutor) { imageProxy -> analyzeFrame(imageProxy) }
                }

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageAnalysis
                )
            } catch (e: Exception) {
                Log.e(TAG, "Camera bind failed", e)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun analyzeFrame(imageProxy: ImageProxy) {
        val recognizer = gestureRecognizer
        if (recognizer == null) {
            imageProxy.close()
            return
        }
        try {
            val bitmap = rgbaImageProxyToBitmap(imageProxy)
            val mpImage: MPImage = BitmapImageBuilder(bitmap).build()

            // Phones report frames in the sensor's native orientation, not
            // upright — this tells MediaPipe how much to rotate before
            // reading the hand, so gestures aren't misread when you're
            // holding the phone normally.
            val processingOptions = ImageProcessingOptions.builder()
                .setRotationDegrees(imageProxy.imageInfo.rotationDegrees)
                .build()

            recognizer.recognizeAsync(mpImage, processingOptions, System.currentTimeMillis())
        } catch (e: Exception) {
            Log.e(TAG, "Frame analysis failed", e)
        } finally {
            imageProxy.close()
        }
    }

    /** Converts CameraX's RGBA_8888 frame data into a standard Bitmap. */
    private fun rgbaImageProxyToBitmap(imageProxy: ImageProxy): Bitmap {
        val plane = imageProxy.planes[0]
        val buffer = plane.buffer
        val pixelStride = plane.pixelStride
        val rowStride = plane.rowStride
        val rowPadding = rowStride - pixelStride * imageProxy.width

        val paddedBitmap = Bitmap.createBitmap(
            imageProxy.width + rowPadding / pixelStride,
            imageProxy.height,
            Bitmap.Config.ARGB_8888
        )
        paddedBitmap.copyPixelsFromBuffer(buffer)

        return if (rowPadding == 0) {
            paddedBitmap
        } else {
            Bitmap.createBitmap(paddedBitmap, 0, 0, imageProxy.width, imageProxy.height)
        }
    }

    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())

    private fun onGestureResult(result: GestureRecognizerResult, input: MPImage) {
        // MediaPipe calls this from its own internal worker thread, but
        // Flutter's EventChannel.success() must be called from the main
        // thread — calling it from here directly crashes with
        // "Methods marked with @UiThread must be executed on the main
        // thread." This hop is what was missing.
        mainHandler.post {
            // Look this up NOW, not at construction time — by the time
            // results are actually flowing, Flutter's side has definitely
            // finished connecting, whereas it may not have been ready yet
            // when this view was first created.
            val eventSink = eventSinkProvider()
            val gestures = result.gestures()
            if (gestures.isEmpty() || gestures[0].isEmpty()) {
                eventSink?.success(mapOf("gesture" to "None", "confidence" to 0.0))
                return@post
            }
            val topGesture = gestures[0][0]
            eventSink?.success(
                mapOf(
                    "gesture" to topGesture.categoryName(),
                    "confidence" to topGesture.score().toDouble()
                )
            )
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        gestureRecognizer?.close()
        gestureRecognizer = null
        analysisExecutor.shutdown()
        lifecycleOwner.registry.currentState = Lifecycle.State.DESTROYED
    }

    companion object {
        private const val TAG = "GestureCameraView"
    }
}

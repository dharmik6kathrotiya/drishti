package com.kaal.drishti

import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.util.Log
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private var landmarker: HandLandmarker? = null
    private var modelPath = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The asset lookup must run on the main thread; detection runs on the worker.
        modelPath = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset("assets/models/hand_landmarker.task")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kaal.drishti/hand").setMethodCallHandler { call, result ->
            if (call.method != "detect") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            if (path == null) {
                result.error("args", "path missing", null)
                return@setMethodCallHandler
            }
            // Detection takes a few hundred milliseconds: keep it off the UI thread.
            worker.execute {
                val out = try {
                    detect(path)
                } catch (e: Throwable) {
                    Log.e("DrishtiHand", "hand detection failed", e)
                    runOnUiThread { result.error("detect", e.message, null) }
                    return@execute
                }
                runOnUiThread { result.success(out) }
            }
        }
    }

    /**
     * Finds one hand in the photo at [path]. Returns the 21 MediaPipe
     * landmarks as [x0, y0, x1, y1, ...] in the photo's own pixel frame
     * (after EXIF rotation, as Flutter shows it), its width and height, and
     * the handedness, or null when no hand is found.
     */
    private fun detect(path: String): Map<String, Any>? {
        val raw = BitmapFactory.decodeFile(path) ?: return null
        val degrees = when (ExifInterface(path).getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90f
            ExifInterface.ORIENTATION_ROTATE_180 -> 180f
            ExifInterface.ORIENTATION_ROTATE_270 -> 270f
            else -> 0f
        }
        val bitmap = if (degrees == 0f) raw else
            android.graphics.Bitmap.createBitmap(raw, 0, 0, raw.width, raw.height, Matrix().apply { postRotate(degrees) }, true)

        val hands = handLandmarker().detect(BitmapImageBuilder(bitmap).build())
        val hand = hands.landmarks().firstOrNull() ?: return null
        val points = ArrayList<Double>(42)
        for (p in hand) {
            points.add((p.x() * bitmap.width).toDouble())
            points.add((p.y() * bitmap.height).toDouble())
        }
        val side = hands.handedness().firstOrNull()?.firstOrNull()?.categoryName() ?: ""
        return mapOf("points" to points, "width" to bitmap.width, "height" to bitmap.height, "handedness" to side)
    }

    private fun handLandmarker(): HandLandmarker = landmarker ?: run {
        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(BaseOptions.builder().setModelAssetPath(modelPath).build())
            .setRunningMode(RunningMode.IMAGE)
            .setNumHands(1)
            .setMinHandDetectionConfidence(0.5f)
            .build()
        HandLandmarker.createFromOptions(applicationContext, options).also { landmarker = it }
    }

    override fun onDestroy() {
        landmarker?.close()
        worker.shutdown()
        super.onDestroy()
    }
}

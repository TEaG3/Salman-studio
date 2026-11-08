#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v flutter >/dev/null 2>&1 || { echo "Flutter SDK is required." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Python 3 is required." >&2; exit 1; }

# Android is the first native target. iOS scaffolding is intentionally deferred.
flutter create --platforms=android,windows --org com.teag3 --project-name tea_g3_studio .

python3 - <<'PY'
from pathlib import Path
import re

root = Path.cwd()
display_name = "TEa.G3-studio"
application_id = "com.teag3.studio"

manifest = root / "android/app/src/main/AndroidManifest.xml"
if not manifest.exists():
    raise SystemExit("Flutter did not generate the Android manifest.")
manifest_text = manifest.read_text()
manifest_text = re.sub(
    r'android:label="[^"]+"',
    f'android:label="{display_name}"',
    manifest_text,
    count=1,
)
manifest.write_text(manifest_text)

gradle_files = (root / "android/app/build.gradle", root / "android/app/build.gradle.kts")
gradle = next((path for path in gradle_files if path.exists()), None)
if gradle is None:
    raise SystemExit("Flutter did not generate the Android app Gradle file.")
gradle_text = gradle.read_text()
if gradle.name.endswith(".kts"):
    gradle_text, count = re.subn(
        r'applicationId\s*=\s*[^\s]+',
        f'applicationId = "{application_id}"',
        gradle_text,
        count=1,
    )
    gradle_text = re.sub(r'minSdk\s*=\s*[^\s]+', 'minSdk = 23', gradle_text, count=1)
    gradle_text = re.sub(r'compileSdk\s*=\s*[^\s]+', 'compileSdk = 36', gradle_text, count=1)
    dependency = '    implementation("androidx.media3:media3-transformer:1.11.1")'
else:
    gradle_text, count = re.subn(
        r'applicationId\s+[^\s]+',
        f'applicationId "{application_id}"',
        gradle_text,
        count=1,
    )
    gradle_text = re.sub(r'minSdkVersion\s+[^\s]+', 'minSdkVersion 23', gradle_text, count=1)
    gradle_text = re.sub(r'compileSdkVersion\s+[^\s]+', 'compileSdkVersion 36', gradle_text, count=1)
    dependency = '    implementation "androidx.media3:media3-transformer:1.11.1"'
if count != 1:
    raise SystemExit("Could not safely set Android applicationId.")
if not re.search(r"compileSdk(?:Version)?\s*(?:=\s*)?36", gradle_text):
    raise SystemExit("Could not safely set Android compileSdk to API 36.")
if "androidx.media3:media3-transformer" not in gradle_text:
    if re.search(r'\ndependencies\s*\{', gradle_text):
        gradle_text = re.sub(
            r'(\ndependencies\s*\{)',
            lambda match: match.group(1) + "\n" + dependency,
            gradle_text,
            count=1,
        )
    else:
        # New Flutter Kotlin DSL templates may not contain a dependencies block.
        gradle_text = gradle_text.rstrip() + "\n\ndependencies {\n" + dependency + "\n}\n"
gradle.write_text(gradle_text)

main_activity = next((root / "android/app/src/main/kotlin").rglob("MainActivity.kt"), None)
if main_activity is None:
    raise SystemExit("Flutter did not generate MainActivity.kt.")
package_name = ".".join(main_activity.relative_to(root / "android/app/src/main/kotlin").parts[:-1])
native_source = r'''package __PACKAGE__

import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

@OptIn(UnstableApi::class)
class MainActivity : FlutterActivity() {
    private val methodName = "com.teag3.studio/media_export"
    private val progressName = "com.teag3.studio/media_export/progress"
    private val handler = Handler(Looper.getMainLooper())
    private val progressHolder = ProgressHolder()
    private var transformer: Transformer? = null
    private var pendingResult: MethodChannel.Result? = null
    private var progressSink: EventChannel.EventSink? = null

    private val progressTask = object : Runnable {
        override fun run() {
            val active = transformer ?: return
            val state = active.getProgress(progressHolder)
            if (state == Transformer.PROGRESS_STATE_AVAILABLE) {
                progressSink?.success(progressHolder.progress)
            }
            if (pendingResult != null) handler.postDelayed(this, 500)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "exportTrim" -> startTrim(call, result)
                    "cancelExport" -> {
                        transformer?.cancel()
                        handler.removeCallbacks(progressTask)
                        pendingResult?.error("EXPORT_CANCELLED", "Export cancelled.", null)
                        pendingResult = null
                        transformer = null
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, progressName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    progressSink = events
                }
                override fun onCancel(arguments: Any?) {
                    progressSink = null
                }
            })
    }

    private fun startTrim(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("EXPORT_BUSY", "Another export is already running.", null)
            return
        }
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")
        val startMs = call.argument<Number>("startMs")?.toLong()
        val endMs = call.argument<Number>("endMs")?.toLong()
        if (inputPath.isNullOrBlank() || outputPath.isNullOrBlank() ||
            startMs == null || endMs == null || startMs < 0 || endMs <= startMs) {
            result.error("INVALID_EXPORT", "Invalid input path or trim range.", null)
            return
        }
        val inputFile = File(inputPath)
        if (!inputFile.isFile || !inputFile.canRead()) {
            result.error("INPUT_UNAVAILABLE", "The source video cannot be read.", null)
            return
        }
        val outputFile = File(outputPath)
        outputFile.parentFile?.mkdirs()
        if (outputFile.exists()) outputFile.delete()

        pendingResult = result
        try {
            val mediaItem = MediaItem.Builder()
                .setUri(Uri.fromFile(inputFile))
                .setClippingConfiguration(
                    MediaItem.ClippingConfiguration.Builder()
                        .setStartPositionMs(startMs)
                        .setEndPositionMs(endMs)
                        .build()
                )
                .build()
            val editedItem = EditedMediaItem.Builder(mediaItem).build()
            transformer = Transformer.Builder(this)
                .addListener(object : Transformer.Listener {
                    override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                        handler.removeCallbacks(progressTask)
                        progressSink?.success(100)
                        val completedFile = File(outputPath)
                        if (!completedFile.isFile || completedFile.length() == 0L) {
                            pendingResult?.error("EMPTY_EXPORT", "Media3 produced no output file.", null)
                        } else {
                            pendingResult?.success(
                                mapOf("path" to outputPath, "fileSizeBytes" to completedFile.length())
                            )
                        }
                        pendingResult = null
                        transformer = null
                    }

                    override fun onError(
                        composition: Composition,
                        exportResult: ExportResult,
                        exportException: ExportException
                    ) {
                        handler.removeCallbacks(progressTask)
                        File(outputPath).delete()
                        pendingResult?.error("EXPORT_FAILED", exportException.message, null)
                        pendingResult = null
                        transformer = null
                    }
                })
                .build()
            transformer?.start(editedItem, outputPath)
            handler.post(progressTask)
        } catch (error: Exception) {
            handler.removeCallbacks(progressTask)
            outputFile.delete()
            pendingResult?.error("EXPORT_FAILED", error.message, null)
            pendingResult = null
            transformer = null
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(progressTask)
        transformer?.cancel()
        pendingResult = null
        transformer = null
        super.onDestroy()
    }
}
'''
main_activity.write_text(native_source.replace("__PACKAGE__", package_name))
print(f"Configured {display_name} ({application_id}) with Media3 Transformer 1.11.1.")
PY

flutter pub get
echo "Android project scaffolding and native MP4 trim export bridge are ready."

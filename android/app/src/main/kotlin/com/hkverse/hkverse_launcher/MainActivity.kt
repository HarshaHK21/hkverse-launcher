package com.hkverse.hkverse_launcher

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

private const val CHANNEL = "hkverse.launcher/apps"

/** Target side (px) for icon PNGs handed to Flutter. */
private const val ICON_SIZE = 108

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> result.success(fetchInstalledApps())
                    "openApp" -> {
                        val packageName = call.argument<String>("packageName")
                        result.success(packageName?.let { openApp(it) } ?: false)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun fetchInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val launchIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfos = pm.queryIntentActivities(launchIntent, 0)
        val apps = mutableListOf<Map<String, Any?>>()
        val seen = HashSet<String>()

        for (info in resolveInfos) {
            val packageName = info.activityInfo.packageName ?: continue
            if (packageName == getPackageName()) continue
            if (!seen.add(packageName)) continue

            apps.add(
                mapOf(
                    "name" to (info.loadLabel(pm)?.toString() ?: packageName),
                    "packageName" to packageName,
                    "activity" to info.activityInfo.name,
                    "icon" to loadIcon(info, packageName),
                )
            )
        }
        return apps
    }

    private fun loadIcon(info: ResolveInfo, packageName: String): ByteArray? {
        return try {
            val drawable: Drawable? = info.loadIcon(packageManager)
                ?: packageManager.getApplicationIcon(packageName)
            val bitmap = drawable?.let { toScaledBitmap(it) } ?: return null
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (_: Exception) {
            null
        }
    }

    /** Draws any Drawable scaled to fit a square [ICON_SIZE] x [ICON_SIZE] box. */
    private fun toScaledBitmap(drawable: Drawable): Bitmap? {
        return try {
            val width = drawable.intrinsicWidth.coerceAtLeast(1)
            val height = drawable.intrinsicHeight.coerceAtLeast(1)
            val scale = minOf(
                ICON_SIZE.toFloat() / width,
                ICON_SIZE.toFloat() / height,
            )
            val scaledW = (width * scale).toInt().coerceAtLeast(1)
            val scaledH = (height * scale).toInt().coerceAtLeast(1)
            val left = (ICON_SIZE - scaledW) / 2
            val top = (ICON_SIZE - scaledH) / 2

            val bitmap = Bitmap.createBitmap(ICON_SIZE, ICON_SIZE, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(left, top, left + scaledW, top + scaledH)
            drawable.draw(canvas)
            bitmap
        } catch (_: Exception) {
            null
        }
    }

    private fun openApp(packageName: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
                )
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (_: Exception) {
            false
        }
    }
}
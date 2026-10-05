package com.example.nav_pos

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingCameraResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "request" -> requestCameraPermission(result)
                    "openSettings" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.fromParts("package", packageName, null),
                            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestCameraPermission(result: MethodChannel.Result) {
        if (checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
            return
        }
        if (pendingCameraResult != null) {
            result.error("busy", "A camera permission request is already in progress", null)
            return
        }
        pendingCameraResult = result
        requestPermissions(arrayOf(Manifest.permission.CAMERA), CAMERA_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != CAMERA_REQUEST_CODE) return
        val result = pendingCameraResult ?: return
        pendingCameraResult = null
        val status = when {
            grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED -> "granted"
            // No rationale after a denial means "Don't ask again" (or blocked by policy).
            shouldShowRequestPermissionRationale(Manifest.permission.CAMERA) -> "denied"
            else -> "permanentlyDenied"
        }
        result.success(status)
    }

    companion object {
        private const val CAMERA_CHANNEL = "nav_pos/camera_permission"
        private const val CAMERA_REQUEST_CODE = 7301
    }
}

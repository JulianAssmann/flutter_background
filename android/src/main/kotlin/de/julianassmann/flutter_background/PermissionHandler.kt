package de.julianassmann.flutter_background

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class PermissionHandler(private val context: Context,
                        private val addActivityResultListener: ((PluginRegistry.ActivityResultListener) -> Unit),
                        private val addRequestPermissionsResultListener: ((PluginRegistry.RequestPermissionsResultListener) -> Unit)) {
    companion object {
        const val PERMISSION_CODE_IGNORE_BATTERY_OPTIMIZATIONS = 5672353
    }

    fun isWakeLockPermissionGranted(): Boolean
    {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.checkSelfPermission(Manifest.permission.WAKE_LOCK) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        };
    }

    fun isIgnoringBatteryOptimizations(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = (context.getSystemService(Context.POWER_SERVICE) as PowerManager)
            powerManager.isIgnoringBatteryOptimizations(context.packageName)
        } else {
            // Before Android M, the battery optimization doesn't exist -> Always "ignoring"
            true
        }
    }

    fun requestBatteryOptimizationsOff(
            result: MethodChannel.Result,
            activity: Activity) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            // Before Android M the battery optimization doesn't exist -> Always "ignoring"
            result.success(true)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = (context.getSystemService(Context.POWER_SERVICE) as PowerManager)
            when {
                powerManager.isIgnoringBatteryOptimizations(context.packageName) -> {
                    result.success(true)
                }
                context.checkSelfPermission(Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS) == PackageManager.PERMISSION_DENIED -> {
                    result.error(
                            "flutter_background.PermissionHandler",
                            "The app does not have the REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission required to ask the user for whitelisting. See the documentation on how to setup this plugin properly.",
                            null)
                }
                else -> {
                    addActivityResultListener(PermissionActivityResultListener(result::success, result::error))
                    val intent = Intent()
                    intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                    intent.data = Uri.parse("package:${context.packageName}")
                    activity.startActivityForResult(intent, PERMISSION_CODE_IGNORE_BATTERY_OPTIMIZATIONS)
                }
            }
        }
    }
}

class PermissionActivityResultListener(
        private val onSuccess: (Any?) -> Unit,
        private val onError: (String, String?, Any?) -> Unit) : PluginRegistry.ActivityResultListener {

    private var alreadyCalled: Boolean = false;
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        try {
            if (alreadyCalled || requestCode != PermissionHandler.PERMISSION_CODE_IGNORE_BATTERY_OPTIMIZATIONS) {
                return false
            }

            alreadyCalled = true

            onSuccess(resultCode == Activity.RESULT_OK)
        } catch (ex: Exception) {
            onError("flutter_background.PermissionHandler", "Error while waiting for user to disable battery optimizations", ex.localizedMessage)
        }

        return true
    }
}
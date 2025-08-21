package de.julianassmann.flutter_background

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import io.flutter.plugin.common.MethodChannel

class PermissionHandler(private val context: Context) {
    companion object {
        private const val TAG = "PermissionHandler"
        private const val TIMEOUT_MS = 60000L
    }

    private var lifecycleCallback: Application.ActivityLifecycleCallbacks? = null
    private var pendingBatteryOptimizationResult: MethodChannel.Result? = null
    private var isWaitingForBatteryOptimization = false

    fun isWakeLockPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.checkSelfPermission(Manifest.permission.WAKE_LOCK) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
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

    fun requestBatteryOptimizationsOff(result: MethodChannel.Result, activity: Activity) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            // Before Android M the battery optimization doesn't exist -> Always "ignoring"
            result.success(true)
            return
        }

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager

        when {
            powerManager.isIgnoringBatteryOptimizations(context.packageName) -> {
                result.success(true)
            }
            context.checkSelfPermission(Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS) == PackageManager.PERMISSION_DENIED -> {
                result.error(
                    "flutter_background.PermissionHandler",
                    "The app does not have the REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission required to ask the user for whitelisting.See the documentation on how to setup this plugin properly.",
                    null
                )
            }
            else -> {
                setupLifecycleDetection(activity, result)

                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                }

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    cleanupLifecycleDetection()
                    result.error("BatteryOptimizationError", "Unable to request battery optimization permission", e.message)
                }
            }
        }
    }

    private fun setupLifecycleDetection(activity: Activity, result: MethodChannel.Result) {
        cleanupLifecycleDetection()

        pendingBatteryOptimizationResult = result
        isWaitingForBatteryOptimization = true

        lifecycleCallback = object : Application.ActivityLifecycleCallbacks {
            private var wasPaused = false
            private val timeoutHandler = Handler(Looper.getMainLooper())
            private val timeoutRunnable = Runnable { handleBatteryOptimizationReturn() }

            override fun onActivityResumed(activity: Activity) {
                if (wasPaused && isWaitingForBatteryOptimization) {
                    timeoutHandler.postDelayed({ handleBatteryOptimizationReturn() }, 500)
                }
            }

            override fun onActivityPaused(activity: Activity) {
                if (isWaitingForBatteryOptimization) {
                    wasPaused = true
                    timeoutHandler.postDelayed(timeoutRunnable, TIMEOUT_MS)
                }
            }

            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {}
        }

        activity.application.registerActivityLifecycleCallbacks(lifecycleCallback)
    }

    private fun cleanupLifecycleDetection() {
        lifecycleCallback?.let { callback ->
                val app = context.applicationContext as Application
                app.unregisterActivityLifecycleCallbacks(callback)
        }
        lifecycleCallback = null
        pendingBatteryOptimizationResult = null
        isWaitingForBatteryOptimization = false
    }

    private fun handleBatteryOptimizationReturn() {
        if (!isWaitingForBatteryOptimization || pendingBatteryOptimizationResult == null) {
            return
        }

        try {
            val isIgnoringBatteryOptimizations = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                powerManager.isIgnoringBatteryOptimizations(context.packageName)
            } else {
                true
            }

            pendingBatteryOptimizationResult?.success(isIgnoringBatteryOptimizations)
        } catch (e: Exception) {
            pendingBatteryOptimizationResult?.error("BatteryOptimizationError", "Error checking permission status", e.message)
        } finally {
            cleanupLifecycleDetection()
        }
    }

    fun cleanup() {
        cleanupLifecycleDetection()
    }
}
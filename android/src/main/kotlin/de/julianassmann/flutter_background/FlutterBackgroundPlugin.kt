package de.julianassmann.flutter_background

import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.security.Permission
import kotlin.coroutines.coroutineContext

public class FlutterBackgroundPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private var methodChannel : MethodChannel? = null
  private var activity: Activity? = null
  private var permissionHandler: PermissionHandler? = null
  private var context: Context? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_background")
      channel.setMethodCallHandler(FlutterBackgroundPlugin())
    }

    @JvmStatic
    var notificationTitle: String? = ""
    @JvmStatic
    var notificationText: String? = ""
    @JvmStatic
    var notificationImportance: Int? = NotificationCompat.PRIORITY_DEFAULT
  }

  @TargetApi(Build.VERSION_CODES.O)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    print(call.method)
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "hasPermissions" -> {
        var hasPermissions = true
        if (!permissionHandler!!.isIgnoringBatteryOptimizations()) {
          hasPermissions = false
        }
        if (!permissionHandler!!.isWakeLockPermissionGranted()) {
          hasPermissions = false;
        }
        result.success(hasPermissions)
      }
      "initialize" -> {
        if (!permissionHandler!!.isWakeLockPermissionGranted()) {
          result.error("PermissionError","Please add the WAKE_LOCK permission to the AndroidManifest.xml in order to use background_sockets.", "")
          return
        }
        if (!permissionHandler!!.isIgnoringBatteryOptimizations()) {
          if (activity != null) {
            permissionHandler!!.requestBatteryOptimizationsOff(result, activity!!)
          } else {
            result.error("NoActivityError", "The plugin is not attached to an activity", "The plugin is not attached to an activity. This is required in order to request battery optimzation to be off.")
          }
        }

        val title = call.argument<String>("android.notificationTitle")
        val text = call.argument<String>("android.notificationText")
        val importance = call.argument<Int>("android.notificationImportance")

        FlutterBackgroundPlugin.notificationImportance = importance ?: NotificationCompat.PRIORITY_DEFAULT
        FlutterBackgroundPlugin.notificationTitle = title ?: "flutter_background foreground service"
        FlutterBackgroundPlugin.notificationText = text ?: "Keeps the flutter app running in the background"
      }
      "enableBackgroundExecution" -> {
        if (!permissionHandler!!.isWakeLockPermissionGranted()) {
          result.error("PermissionError", "Please add the WAKE_LOCK permission to the AndroidManifest.xml in order to use background_sockets.", "")
          return
        }
        if (!permissionHandler!!.isIgnoringBatteryOptimizations()) {
          result.error("PermissionError", "The battery optimizations are not turned off.", "")
          return
        }
        context!!.startForegroundService(Intent(context, IsolateHolderService::class.java))
        result.success(true)
      }
      "disableBackgroundExecution" -> {
        val intent = Intent(context!!, IsolateHolderService::class.java)
        intent.action = IsolateHolderService.ACTION_SHUTDOWN
        context!!.startForegroundService(intent)
        result.success(true)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    startListening(binding.applicationContext, binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    stopListening()
  }

  override fun onDetachedFromActivity() {
    stopListeningToActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    startListeningToActivity(
            binding.activity,
            binding::addActivityResultListener,
            binding::addRequestPermissionsResultListener)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  private fun startListening(applicationContext: Context, messenger: BinaryMessenger) {
    methodChannel = MethodChannel(
            messenger,
            "flutter_background"
    )
    methodChannel!!.setMethodCallHandler(this)
    context = applicationContext
  }

  private fun stopListening() {
    methodChannel!!.setMethodCallHandler(null)
    methodChannel = null
    context = null
  }

  private fun startListeningToActivity(
          activity: Activity,
          addActivityResultListener: ((PluginRegistry.ActivityResultListener) -> Unit),
          addRequestPermissionResultListener: ((PluginRegistry.RequestPermissionsResultListener) -> Unit)
  ) {
    this.activity = activity
    permissionHandler = PermissionHandler(
            activity.applicationContext,
            addActivityResultListener,
            addRequestPermissionResultListener)
  }

  private fun stopListeningToActivity() {
    this.activity = null
    permissionHandler = null
  }
}

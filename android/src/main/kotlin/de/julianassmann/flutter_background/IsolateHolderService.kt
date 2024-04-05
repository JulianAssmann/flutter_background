package de.julianassmann.flutter_background

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class IsolateHolderService : Service() {
    companion object {
        @JvmStatic
        val ACTION_SHUTDOWN = "SHUTDOWN"
        @JvmStatic
        val ACTION_START = "START"
        @JvmStatic
        val WAKELOCK_TAG = "FlutterBackgroundPlugin:Wakelock"
        @JvmStatic
        val WIFILOCK_TAG = "FlutterBackgroundPlugin:WifiLock"
        @JvmStatic
        val CHANNEL_ID = "flutter_background"
        @JvmStatic
        private val TAG = "IsolateHolderService"
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onBind(intent: Intent) : IBinder? {
        return null
    }

    override fun onCreate() {
        FlutterBackgroundPlugin.loadNotificationConfiguration(applicationContext)
    }
    
    override fun onDestroy() {
        cleanupService()
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int) : Int {
        if (intent?.action == ACTION_SHUTDOWN) {
            cleanupService()
            stopSelf()
        } else if (intent?.action == ACTION_START) {
            startService()
        }
        return START_STICKY
    }

    private fun cleanupService() {
        wakeLock?.apply {
            if (isHeld) {
                release()
            }
        }

        if (FlutterBackgroundPlugin.enableWifiLock) {
            wifiLock?.apply {
                if (isHeld) {
                    release()
                }
            }
        }

        stopForeground(true)
    }

    @SuppressLint("WakelockTimeout")
    private fun startService() {
        val pm = applicationContext.packageManager
        val notificationIntent  =
            pm.getLaunchIntentForPackage(applicationContext.packageName)

        // See https://developer.android.com/guide/components/intents-filters#DeclareMutabilityPendingIntent
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT > 23) flags = flags or PendingIntent.FLAG_IMMUTABLE

        val pendingIntent  = PendingIntent.getActivity(
            this, 0,
            notificationIntent, flags
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                FlutterBackgroundPlugin.notificationTitle,
                FlutterBackgroundPlugin.notificationImportance).apply {
                description = FlutterBackgroundPlugin.notificationText
            }
            channel.setShowBadge(FlutterBackgroundPlugin.showBadge)
            // Register the channel with the system
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        val imageId = resources.getIdentifier(FlutterBackgroundPlugin.notificationIconName, FlutterBackgroundPlugin.notificationIconDefType, packageName)
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(FlutterBackgroundPlugin.notificationTitle)
            .setContentText(FlutterBackgroundPlugin.notificationText)
            .setSmallIcon(imageId)
            .setContentIntent(pendingIntent)
            .setPriority(FlutterBackgroundPlugin.notificationImportance)
            .build()

        (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            wakeLock = newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                setReferenceCounted(false)
                acquire()
            }
        }

        (applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager).run {
            wifiLock = createWifiLock(WifiManager.WIFI_MODE_FULL, WIFILOCK_TAG).apply {
                setReferenceCounted(false)
                acquire()
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                1,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE);
        } else {
            startForeground(
                1,
                notification);
        }
    }

    override fun onTaskRemoved(rootIntent: Intent) {
        super.onTaskRemoved(rootIntent)
        cleanupService()
        stopSelf()
    }
}

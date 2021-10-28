package de.julianassmann.flutter_background

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
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
        val CHANNEL_ID = "flutter_background"
        @JvmStatic
        private val TAG = "IsolateHolderService"
        @JvmStatic
        val EXTRA_NOTIFICATION_IMPORTANCE = "de.julianassmann.flutter_background:Importance"
        @JvmStatic
        val EXTRA_NOTIFICATION_TITLE = "de.julianassmann.flutter_background:Title"
        @JvmStatic
        val EXTRA_NOTIFICATION_TEXT = "de.julianassmann.flutter_background:Text"
    }

    override fun onBind(intent: Intent) : IBinder? {
        return null
    }

    @SuppressLint("WakelockTimeout")
    override fun onCreate() {
        FlutterBackgroundPlugin.loadNotificationConfiguration(applicationContext)

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
                    FlutterBackgroundPlugin.notificationImportance ?: NotificationCompat.PRIORITY_DEFAULT).apply {
                description = FlutterBackgroundPlugin.notificationText
            }
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
                .setPriority(FlutterBackgroundPlugin.notificationImportance ?: NotificationCompat.PRIORITY_DEFAULT)
                .build()

        (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                setReferenceCounted(false)
                acquire()
            }
        }
        startForeground(1, notification)

        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int) : Int {
        if (intent?.action == ACTION_SHUTDOWN) {
            (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
                newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                    if (isHeld) {
                        release()
                    }
                }
            }
            stopForeground(true)
            stopSelf()
        }
        return START_STICKY
    } 

    override fun onTaskRemoved(rootIntent: Intent) {
        super.onTaskRemoved(rootIntent)
        stopSelf()
    }
}

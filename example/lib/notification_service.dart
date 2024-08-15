import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint("Notification tapped in background: ${notificationResponse.payload}");
}

/// The service used to display notifications and handle callbacks when the user taps on the notification.
///
/// This is a singleton. Just call NotificationService() to get the singleton.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  late FlutterLocalNotificationsPlugin plugin;

  NotificationService._internal() {
    plugin = FlutterLocalNotificationsPlugin();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        debugPrint('Received iOS notification: $id, $title, $body, $payload');
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        debugPrint('Notification received: ${notificationResponse.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // For Android
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // For iOS
    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> initialize() async {
    _instance._requestPermissions();
  }

  Future<void> newNotification(String msg, bool vibration) async {
    // Define vibration pattern
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    const channelName = 'Text messages';

    final androidNotificationDetails = AndroidNotificationDetails(
      channelName,
      channelName,
      channelDescription: channelName,
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: vibration ? vibrationPattern : null,
      enableVibration: vibration,
      visibility: NotificationVisibility.public,
    );

    const darwinNotificationDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    try {
      await plugin.show(0, 'New Message', msg, notificationDetails, payload: msg);
    } catch (ex) {
      debugPrint('Error showing notification: $ex');
    }
  }
}
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The service used to display notifications and handle callbacks when the user taps on the notification.
///
/// This is a singleton. Just call NotificationService() to get the singleton.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  late FlutterLocalNotificationsPlugin plugin;

  NotificationService._internal() {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    plugin = FlutterLocalNotificationsPlugin();
    plugin.initialize(initializationSettings);
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
    );

    const darwinNotificationDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    try {
      await plugin.show(0, msg, msg, notificationDetails);
    } catch (ex) {
      print(ex);
    }
  }
}
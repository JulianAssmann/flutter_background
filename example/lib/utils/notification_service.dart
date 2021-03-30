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
    final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings());

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

    AndroidNotificationDetails androidNotificationDetails;

    final channelName = 'Text messages';

    androidNotificationDetails = AndroidNotificationDetails(
        channelName, channelName, channelName,
        importance: Importance.max,
        priority: Priority.high,
        vibrationPattern: vibration ? vibrationPattern : null,
        enableVibration: vibration);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails, 
        iOS: iOSPlatformChannelSpecifics);

    try {
      await plugin.show(0, msg, msg, notificationDetails);
    } catch (ex) {
      print(ex);
    }
  }
}

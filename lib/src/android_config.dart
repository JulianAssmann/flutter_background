/// Represents the importance of an android notification as described
/// under https://developer.android.com/training/notify-user/channels#importance.
enum AndroidNotificationImportance {
  Default,
  Min,
  Low,
  High,
  Max,
}

/// Android configuration for the [FlutterBackground] plugin.
class FlutterBackgroundAndroidConfig {
  /// The importance of the notification used for the foreground service.
  final AndroidNotificationImportance notificationImportance;

  /// The title used for the foreground service notification.
  final String notificationTitle;

  /// The body used for the foreground service notification.
  final String notificationText;

  /// Creates an Android specific configuration for the [FlutterBackground] plugin.
  ///
  /// [notificationTitle] is the title used for the foreground service notification.
  /// [notificationText] is the body used for the foreground service notification.
  /// [notificationImportance] is the importance of the foreground service notification.
  /// It must be greater than [AndroidNotificationImportance.Min].
  const FlutterBackgroundAndroidConfig(
      {this.notificationTitle = "Notification title",
      this.notificationText = "Notification text",
      this.notificationImportance = AndroidNotificationImportance.Default})
      : assert(notificationTitle != null),
        assert(notificationText != null),
        assert(notificationImportance != null);
}

/// Represents the importance of an android notification as described
/// under https://developer.android.com/training/notify-user/channels#importance.
enum AndroidNotificationImportance {
  Default,
  Min,
  Low,
  High,
  Max,
}

// Represents the information required to get an Android resource.
// See https://developer.android.com/reference/android/content/res/Resources for reference.
class AndroidResource {
  // The name of the desired resource.
  final String name;

  // Optional default resource type to find, if "type/" is not included in the name. Can be null to require an explicit type.
  final String defType;

  const AndroidResource({required this.name, this.defType = 'drawable'});
}

/// Android configuration for the [FlutterBackground] plugin.
class FlutterBackgroundAndroidConfig {
  /// The importance of the notification used for the foreground service.
  final AndroidNotificationImportance notificationImportance;

  /// The title used for the foreground service notification.
  final String notificationTitle;

  /// The body used for the foreground service notification.
  final String notificationText;

  /// The resource name of the icon to be used for the foreground notification.
  final AndroidResource notificationIcon;

  /// Creates an Android specific configuration for the [FlutterBackground] plugin.
  ///
  /// [notificationTitle] is the title used for the foreground service notification.
  /// [notificationText] is the body used for the foreground service notification.
  /// [notificationImportance] is the importance of the foreground service notification.
  /// [notificationIcon] must be a drawable resource.
  /// E. g. if the icon with name "background_icon" is in the "drawable" resource folder,
  /// [notificationIcon] should be of value `AndroidResource(name: 'background_icon', defType: 'drawable').
  /// It must be greater than [AndroidNotificationImportance.Min].
  const FlutterBackgroundAndroidConfig(
      {this.notificationTitle = 'Notification title',
      this.notificationText = 'Notification text',
      this.notificationImportance = AndroidNotificationImportance.Default,
      this.notificationIcon =
          const AndroidResource(name: 'ic_launcher', defType: 'mipmap')});
}

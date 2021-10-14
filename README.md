# flutter_background

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/julianassmann)


A plugin to keep flutter apps running in the background. Currently only works with Android.

It achieves this functionality by running an [Android foreground service](https://developer.android.com/guide/components/foreground-services) in combination with a [partial wake lock](https://developer.android.com/training/scheduling/wakelock#cpu) and [disabling battery optimizations](https://developer.android.com/training/monitoring-device-state/doze-standby#support_for_other_use_cases) in order to keep the flutter isolate running.

**Note:** This plugin currently only works with Android.
PRs for iOS are very welcome, although I am not sure if a similiar effect can be achieved with iOS at all.

## Getting started

To use this plugin, add `flutter_background` as a [dependency in your `pubspec.yaml` file](https://pub.dev/packages/flutter_background/install).

### Android

Add the following permissions to the `AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="de.julianassmann.flutter_background_example">

    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

    <application>
    ...
    </application>
</manifest>
```

### iOS

iOS is currently not supported.

## Usage

Import `flutter_background.dart`:

```dart
import 'package:flutter_background/flutter_background.dart';
```

### Initializing plugin and handling permissions

Before you can use this plugin, you need to initialize it by calling `FlutterBackground.initialize(...)`:

```dart
final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText: "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
);
bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
```

This ensures all permissions are granted and requests them if necessary. It also configures the
foreground notification. The configuration above results in the foreground notification shown below when
running `FlutterBackground.enableBackgroundExecution()`.

![The foreground notification created by the code above.](./images/notification.png "The foreground notification created by the code above.")

The arguments are:
- `notificationTitle`: The title used for the foreground service notification.
- `notificationText`: The body used for the foreground service notification.
- `notificationImportance`: The importance of the foreground service notification.
- `notificationIcon`: The icon used for the foreground service notification shown in the top left corner. This must be a drawable Android Resource (see [here](https://developer.android.com/reference/android/app/Notification.Builder#setSmallIcon(int,%20int)) for more). E. g. if the icon with name "background_icon" is in the "drawable" resource folder, it should be of value `AndroidResource(name: 'background_icon', defType: 'drawable').
- `enableWifiLock`: Indicates whether or not a WifiLock is acquired when background execution is started. This allows the application to keep the Wi-Fi radio awake, even when the user has not used the device in a while (e.g. for background network communications).

In this example, `background_icon` is a drawable resource in the `drawable` folders (see the example app).
For more information check out the [Android documentation for creating notification icons](https://developer.android.com/studio/write/image-asset-studio#create-notification) for more information how to create and store an icon.  

In order to function correctly, this plugin needs a few permissions.
`FlutterBackground.initialize(...)` will request permissions from the user if necessary.
You can call initialize more than one time, so you can call `initalize()` every time before you call `enableBackgroundExecution()` (see below).

In order to notify the user about upcoming permission requests by the system, you need to know, whether or not the app already has these permissions. You can find out by calling

```dart
bool hasPermissions = await FlutterBackground.hasPermissions;
```
before calling `FlutterBackground.initialize(...)`. If the app already has all necessary permissions, no permission requests will be displayed to the user.

### Run app in background

With

```dart
bool success = await FlutterBackground.enableBackgroundExecution();
```

you can try to get the app running in the background. You must call `FlutterBackground.initialize()` before calling `FlutterBackground.enableBackgroundExecution()`.

With

```dart
await FlutterBackground.disableBackgroundExecution();
```

you can stop the background execution of the app. You must call `FlutterBackground.initialize()` before calling `FlutterBackground.disableBackgroundExecution()`.

To check whether background execution is currently enabled, use

```dart
bool enabled = FlutterBackground.isBackgroundExecutionEnabled;
```

## Example

The example is a TCP chat app: It can connect to a TCP server and send and receive messages. The user is notified about incoming messages by notifications created with the plugin [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications).

Using this plugin, the example app can maintain the TCP connection with the server, receiving messages and creating notifications for the user even when in the background.

## Maintainer

[Julian Aßmann](https://github.com/JulianAssmann)

If you experience any problems with this package, please [create an issue on Github](https://github.com/JulianAssmann/flutter_background/issues).
Pull requests are also very welcome.

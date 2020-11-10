# flutter_background

A plugin to keep flutter apps running in the background. Currently only works with Android.

It achives this functionality by running an [Android foreground service](https://developer.android.com/guide/components/foreground-services) in combination with a [partial wake lock](https://developer.android.com/training/scheduling/wakelock#cpu) and [disabling battery optimizations](https://developer.android.com/training/monitoring-device-state/doze-standby#support_for_other_use_cases) in order to keep the flutter isolate running.

**Note:** This plugin currently only works with Android.
PRs for iOS are very welcome, although I am not sure if a similiar effect can be achieved with iOS at all.

## Getting started

To use this plugin, add `flutter_background` as a [dependency in your `pubspec.yaml` file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

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
    notificationTitle: "Title of the notification",
    notificationText: "Text of the notification",
    importance: AndroidNotificationImportance.Default,
);
bool success = await FlutterBackground.initialize(androidConfig: androidconfig);
```

In order to function correctly, this plugin needs a few permissions. `FlutterBackground.initialize(...)` will request permissions from the user if necessary.

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
await FlutterBackground.disbleBackgroundExecution();
```

you can stop the background execution of the app. You must call `FlutterBackground.initialize()` before calling `FlutterBackground.disbleBackgroundExecution()`.

## Example

The example is a TCP chat app: It can connect to a TCP server and send and receive messages. The user is notified about incoming messages by notifications created with the plugin [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications).

Using this plugin, the example app can maintain the TCP connection with the server, receiving messages and creating notifications for the user even when in the background.

## Maintainers

* [Julian Aßmann](https://github.com/JulianAssmann)

Pull requests are always very welcome. If you know a way to enable background execution of flutter apps in iOS, I would love to see a pull request implementing it.

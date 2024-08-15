## 1.3.0+1

* Update README to not include unecessary `<uses-permission>` in example `AndroidManifest.xml`, as these are already defined in the plugins `AndroidManifest.xml`
* Remove uncecessary double if statement in example app

## 1.3.0

* **Breaking**: Support for Android 14 and above, as all foreground service must list at least one foreground service type for each service. This requires users to define
* Remove references to deprecated v1 Android embedding as it will be removed in Flutter 3.26 (see the [Flutter 3.22 release notes](https://medium.com/flutter/whats-new-in-flutter-3-22-fbde6c164fe3) and the [migration guide](https://docs.flutter.dev/release/breaking-changes/plugin-api-migration))
* Move Gradle from imperative apply to declarative plugins (see [here](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply) for more information)
* Move the example project to a new version of the [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) to get the notifications running again in the latest versions of Android

## 1.2.0

* Add option to hide notification badge
* Add option to not request battery optimization permission
* Add support for gradle 7.3+

## 1.1.0

* Add capability to enable Android Wifi Lock in the initialize function.

## 1.0.2+2

* Fix crash when targeting Android S+ due to a missing immutable flag for pending intents

## 1.0.2+1

* Simplified example application by removing the use of the BLoC pattern

## 1.0.2

* Remove foreground service notification importance levels that cause an error on Android

## 1.0.1

* Tapping on the foreground notification now launches the Flutter Activity on Android
* Fix `null` Intent error for onStartCommand on Android

## 1.0.0

* Add null safety

## 0.1.6

* Improve initialize method on Android
* Add ability to specify custom notification icons
* Update documentation accordingly

## 0.1.5

* Add `isBackgroundExecutionEnabled` property to enable checking the current background execution state

## 0.1.4

* Fix bug where calling `FlutterBackground.initialize()` for the first time crashes the app
* Fix bug where calling `FlutterBackground.hasPermissions` for the first time crashes the app
* Fix some typos
* Address notification icon in the documentation
* Enhance error handling in example app

## 0.1.3

* Stop IsolateHolderService when app is killed with swipe to remove

## 0.1.2

* Fix problem where the plugin crashes when specifying the android configuration calling `FlutterBackground.initialize()`
* Introduce ToDo section in the README.md
* Fix some typos
* Add analysis_options.yaml based on pedantic v. 1.9.0 for static analysis and conform to it
* Update example app and server

## 0.1.1

* Conform to dart formatting standards to improve pub.dev score

## 0.1.0

* First release of the plugin for android
* Add example TCP chat app
* Add TCP server for the example app to talk to
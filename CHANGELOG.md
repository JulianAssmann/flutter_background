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

* Add `isBackgroundExecutionEnabled` property to enable checking the current background execution state.

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
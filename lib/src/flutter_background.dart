import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_background/src/android_config.dart';

class FlutterBackground {
  static const MethodChannel _channel = MethodChannel('flutter_background');

  static bool _isInitialized = false;
  static bool _isBackgroundExecutionEnabled = false;

  /// Initializes the plugin.
  /// May request the necessary permissions from the user in order to run in the background.
  ///
  /// Does nothing and returns true if the permissions are already granted.
  /// Returns true, if the user grants the permissions, otherwise false.
  /// May throw a [PlatformException].
  static Future<bool> initialize(
      {FlutterBackgroundAndroidConfig androidConfig =
          const FlutterBackgroundAndroidConfig()}) async {
    _isInitialized = await _channel.invokeMethod<bool>('initialize', {
          'android.notificationTitle': androidConfig.notificationTitle,
          'android.notificationText': androidConfig.notificationText,
          'android.notificationImportance': _androidNotificationImportanceToInt(
              androidConfig.notificationImportance),
          'android.notificationIconName': androidConfig.notificationIcon.name,
          'android.notificationIconDefType':
              androidConfig.notificationIcon.defType,
        }) ==
        true;
    return _isInitialized;
  }

  /// Indicates whether or not the user has given the necessary permissions in order to run in the background.
  ///
  /// Returns true, if the user has granted the permission, otherwise false.
  /// May throw a [PlatformException].
  static Future<bool> get hasPermissions async {
    return await _channel.invokeMethod<bool>('hasPermissions') == true;
  }

  /// Enables the execution of the flutter app in the background.
  /// You must to call [FlutterBackground.initialize()] before calling this function.
  ///
  /// Returns true if successful, otherwise false.
  /// Throws an [Exception] if the plugin is not initialized by calling [FlutterBackground.initialize()] first.
  /// May throw a [PlatformException].
  static Future<bool> enableBackgroundExecution() async {
    if (_isInitialized) {
      final success =
          await _channel.invokeMethod<bool>('enableBackgroundExecution');
      _isBackgroundExecutionEnabled = true;
      return success == true;
    } else {
      throw Exception(
          'FlutterBackground plugin must be initialized before calling enableBackgroundExecution()');
    }
  }

  /// Disables the execution of the flutter app in the background.
  /// You must to call [FlutterBackground.initialize()] before calling this function.
  ///
  /// Returns true if successful, otherwise false.
  /// Throws an [Exception] if the plugin is not initialized by calling [FlutterBackground.initialize()] first.
  /// May throw a [PlatformException].
  static Future<bool> disableBackgroundExecution() async {
    if (_isInitialized) {
      final success =
          await _channel.invokeMethod<bool>('disableBackgroundExecution');
      _isBackgroundExecutionEnabled = false;
      return success == true;
    } else {
      throw Exception(
          'FlutterBackground plugin must be initialized before calling disableBackgroundExecution()');
    }
  }

  /// Indicates whether background execution is currently enabled.
  static bool get isBackgroundExecutionEnabled => _isBackgroundExecutionEnabled;

  static int _androidNotificationImportanceToInt(
      AndroidNotificationImportance importance) {
    switch (importance) {
      case AndroidNotificationImportance.Low:
        return -1;
      case AndroidNotificationImportance.Min:
        return -2;
      case AndroidNotificationImportance.High:
        return 1;
      case AndroidNotificationImportance.Max:
        return 2;
      case AndroidNotificationImportance.Default:
      default:
        return 0;
    }
  }
}

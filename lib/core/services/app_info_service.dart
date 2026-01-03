import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

/// Service to get app information like version and platform.
/// This follows the singleton pattern to ensure efficient initialization.
class AppInfoService {
  static AppInfoService? _instance;
  static AppInfoService get instance {
    _instance ??= AppInfoService._internal();
    return _instance!;
  }

  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  AppInfoService._internal();

  /// Initialize the service by fetching package info.
  /// Should be called once at app startup.
  Future<void> initialize() async {
    if (!_isInitialized) {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
    }
  }

  /// Gets the app version in format: major.minor.patch
  /// Example: 1.0.0
  String get version {
    if (_packageInfo == null) {
      throw Exception(
          'AppInfoService not initialized. Call initialize() first.');
    }
    return _packageInfo!.version;
  }

  /// Gets the platform name: 'android', 'ios', 'web', etc.
  String get platform {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Gets the build number
  String get buildNumber {
    if (_packageInfo == null) {
      throw Exception(
          'AppInfoService not initialized. Call initialize() first.');
    }
    return _packageInfo!.buildNumber;
  }

  /// Gets the app name
  String get appName {
    if (_packageInfo == null) {
      throw Exception(
          'AppInfoService not initialized. Call initialize() first.');
    }
    return _packageInfo!.appName;
  }

  /// Gets the package name
  String get packageName {
    if (_packageInfo == null) {
      throw Exception(
          'AppInfoService not initialized. Call initialize() first.');
    }
    return _packageInfo!.packageName;
  }
}


import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../models/fingerprint.dart';

/// Device Information Utility
///
/// Provides methods to extract device information matching the web project's
/// `extract-device-info.ts` implementation. This ensures consistency between
/// Flutter app and web browser device registration.
///
/// All methods are static and follow the Single Responsibility Principle.
class DeviceInfoUtil {
  static const String _deviceTokenKey = 'device_token';
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get or generate a unique device token
  ///
  /// Uses platform-specific identifiers when available for better uniqueness.
  /// Falls back to UUID if platform ID is not available.
  ///
  /// Returns: A unique device token string
  static Future<String> getDeviceToken() async {
    String? token = StorageService.getString(_deviceTokenKey);
    if (token == null || token.isEmpty) {
      // Use actual hardware ID if available, otherwise fallback to UUID
      token = await getPlatformDeviceId() ?? const Uuid().v4();
      StorageService.setString(_deviceTokenKey, token);
    }
    return token;
  }

  /// Get platform-specific device identifier
  ///
  /// - Android: Returns Android ID
  /// - iOS: Returns identifierForVendor
  /// - Other platforms: Returns null
  ///
  /// Returns: Platform-specific device ID or null if unavailable
  static Future<String?> getPlatformDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor; // Vendor ID
      }
    } catch (_) {
      // Return null if unable to get platform ID
    }
    return null;
  }

  /// Get OS name matching web project format
  ///
  /// Returns OS name as string (e.g., 'Android', 'iOS', 'Windows', etc.)
  /// Matches the format used in the web project's user agent detection.
  ///
  /// Returns: OS name string
  static String getOS() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Get Browser name
  ///
  /// For mobile apps, returns 'App'. For web, returns 'Web Browser'.
  /// This matches the browser field in device registration requests.
  ///
  /// Returns: Browser name string
  static String getBrowser() {
    if (kIsWeb) return 'Web Browser';
    return 'App';
  }

  /// Get IANA Timezone
  ///
  /// Returns the device's timezone in IANA format (e.g., 'Asia/Riyadh').
  /// Falls back to system timezone name if FlutterTimezone fails.
  ///
  /// Returns: Timezone string
  static Future<String> getTimezone() async {
    try {
      // FlutterTimezone.getLocalTimezone() returns timezone string (e.g., "Asia/Riyadh")
      final timezone = await FlutterTimezone.getLocalTimezone();
      return timezone.toString();
    } catch (_) {
      return DateTime.now().timeZoneName;
    }
  }

  /// Generate full device fingerprint
  ///
  /// Note: For accurate screen dimensions, use [getFingerprintWithContext]
  /// with a BuildContext instead.
  ///
  /// Returns: [Fingerprint] containing all device information
  static Future<Fingerprint> getFingerprint() async {
    return getFingerprintWithContext(null);
  }

  /// Generate full device fingerprint with BuildContext for accurate screen info
  ///
  /// Matches exactly the web project's `extractDeviceInfo()` function.
  /// Uses context for accurate logical pixel screen dimensions when available.
  ///
  /// **Important**: Context is used synchronously before any async operations
  /// to avoid BuildContext usage across async gaps.
  ///
  /// Parameters:
  /// - [context]: Optional BuildContext for accurate screen dimensions
  ///
  /// Returns: [Fingerprint] containing all device information
  static Future<Fingerprint> getFingerprintWithContext(
    BuildContext? context,
  ) async {
    // Extract screen dimensions synchronously before async operations
    // This avoids BuildContext usage across async gaps
    final screenDimensions = _getScreenDimensions(context);

    // Now proceed with async operations
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final hardwareConcurrency = Platform.numberOfProcessors;
    final ramGB = await _getRamGB();
    final maxTouchPoints = await _getMaxTouchPoints();
    final userAgent = await _buildUserAgent(packageInfo);

    return Fingerprint(
      user_agent: userAgent,
      screen: FingerprintScreen(
        width: screenDimensions.width,
        height: screenDimensions.height,
      ),
      ram: ramGB,
      hardware_concurrency: hardwareConcurrency,
      max_touch_points: maxTouchPoints,
      browser: getBrowser(),
      os: getOS(),
      deviceType: Platform.isAndroid
          ? 'Mobile'
          : Platform.isIOS
          ? 'Mobile'
          : 'Desktop',
    );
  }

  /// Get screen dimensions in logical pixels
  ///
  /// Matches `window.screen.width/height` behavior from web browsers.
  /// Uses MediaQuery when context is available, otherwise falls back to PlatformDispatcher.
  ///
  /// Parameters:
  /// - [context]: Optional BuildContext for accurate dimensions
  ///
  /// Returns: Record containing width and height in logical pixels
  static ({int width, int height}) _getScreenDimensions(BuildContext? context) {
    if (context != null) {
      final mediaQuery = MediaQuery.of(context);
      return (
        width: mediaQuery.size.width.round(),
        height: mediaQuery.size.height.round(),
      );
    }

    // Fallback to PlatformDispatcher
    final view = ui.PlatformDispatcher.instance.implicitView;
    if (view != null) {
      final devicePixelRatio = view.devicePixelRatio;
      return (
        width: (view.physicalSize.width / devicePixelRatio).round(),
        height: (view.physicalSize.height / devicePixelRatio).round(),
      );
    }

    return (width: 0, height: 0);
  }

  /// Get RAM in GB, rounded to nearest power of 2 (matching navigator.deviceMemory)
  static Future<int> _getRamGB() async {
    try {
      double rawGB = 0;

      if (Platform.isAndroid) {
        rawGB = await _getAndroidRamGB();
      } else if (Platform.isIOS) {
        rawGB = await _getIOSRamGB();
      }

      return _roundToNearestPowerOf2(rawGB);
    } catch (_) {
      return 0; // navigator.deviceMemory returns 0 if not available
    }
  }

  /// Get RAM from Android /proc/meminfo
  ///
  /// Reads total memory from /proc/meminfo and converts to GB.
  ///
  /// Returns: RAM in GB (raw value, not rounded)
  static Future<double> _getAndroidRamGB() async {
    try {
      final memInfo = await File('/proc/meminfo').readAsLines();
      final totalMemLine = memInfo.firstWhere(
        (line) => line.startsWith('MemTotal:'),
        orElse: () => '',
      );
      if (totalMemLine.isEmpty) return 0;

      final totalMemKb =
          int.tryParse(totalMemLine.split(RegExp(r'\s+'))[1]) ?? 0;
      if (totalMemKb <= 0) return 0;

      return totalMemKb / (1024 * 1024); // Convert KB to GB
    } catch (_) {
      return 0;
    }
  }

  /// Get RAM from iOS SystemInfoPlus
  ///
  /// Uses SystemInfoPlus to get physical memory and converts to GB.
  ///
  /// Returns: RAM in GB (raw value, not rounded)
  static Future<double> _getIOSRamGB() async {
    try {
      final memoryBytes = await SystemInfoPlus.physicalMemory;
      if (memoryBytes == null || memoryBytes <= 0) return 0;
      return memoryBytes / (1024 * 1024 * 1024); // Convert bytes to GB
    } catch (_) {
      return 0;
    }
  }

  /// Round RAM value to nearest power of 2
  ///
  /// Matches `navigator.deviceMemory` behavior which returns powers of 2.
  ///
  /// Parameters:
  /// - [rawGB]: Raw RAM value in GB
  ///
  /// Returns: Rounded RAM value (power of 2)
  static int _roundToNearestPowerOf2(double rawGB) {
    if (rawGB <= 1) return 1;
    if (rawGB <= 2) return 2;
    if (rawGB <= 4) return 4;
    if (rawGB <= 6) return 4; // Round down to 4GB
    if (rawGB <= 8) return 8;
    if (rawGB <= 12) return 8; // Round down to 8GB
    if (rawGB <= 16) return 16;
    return (rawGB / 2).round() * 2; // Round to nearest power of 2
  }

  /// Get max touch points (matching navigator.maxTouchPoints)
  /// Most web browsers return 5 for modern touch devices, even if hardware supports 10+
  static Future<int> _getMaxTouchPoints() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidMaxTouchPoints();
      } else if (Platform.isIOS) {
        return 5; // iOS devices: navigator.maxTouchPoints returns 5
      }
      return 0; // Desktop or other platforms
    } catch (_) {
      return 0;
    }
  }

  /// Get max touch points from Android system features
  ///
  /// Checks system features to determine multitouch capabilities.
  /// Returns 5 for multitouch devices (matching web browser behavior).
  ///
  /// Returns: Maximum touch points (5, 1, or 0)
  static Future<int> _getAndroidMaxTouchPoints() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      final features = androidInfo.systemFeatures;

      if (features.contains(
            'android.hardware.touchscreen.multitouch.distinct',
          ) ||
          features.contains(
            'android.hardware.touchscreen.multitouch.jazzhand',
          )) {
        return 5; // Web browsers return 5 for multitouch devices
      } else if (features.contains('android.hardware.touchscreen')) {
        return 1; // Single touch only
      }
      return 5; // Default for Android devices
    } catch (_) {
      return 0;
    }
  }

  /// Build user agent string (matching web's navigator.userAgent format)
  static Future<String> _buildUserAgent(PackageInfo packageInfo) async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return 'SurveySystemApp/${packageInfo.version} '
            '(${androidInfo.brand} ${androidInfo.model}; '
            'Android ${androidInfo.version.release}; '
            '${androidInfo.hardware})';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return 'SurveySystemApp/${packageInfo.version} '
            '(iPhone; iOS ${iosInfo.systemVersion}; '
            '${iosInfo.utsname.machine})';
      }
      return 'SurveySystemApp/${packageInfo.version}';
    } catch (_) {
      return 'SurveySystemApp/${packageInfo.version}';
    }
  }
}

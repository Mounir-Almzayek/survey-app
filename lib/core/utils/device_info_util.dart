import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../../features/auth/models/researcher_login_fingerprint.dart';
import '../../features/auth/models/researcher_login_screen.dart';

class DeviceInfoUtil {
  static const String _deviceTokenKey = 'device_token';
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get or generate a unique device token
  /// Uses platform-specific identifiers when available for better uniqueness
  static Future<String> getDeviceToken() async {
    String? token = StorageService.getString(_deviceTokenKey);
    if (token == null || token.isEmpty) {
      // Use actual hardware ID if available, otherwise fallback to UUID
      token = await getPlatformDeviceId() ?? const Uuid().v4();
      StorageService.setString(_deviceTokenKey, token);
    }
    return token;
  }

  /// Get platform-specific device identifier (for additional verification)
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
  static String getOS() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Get Browser name (for mobile apps, we return 'App')
  static String getBrowser() {
    if (kIsWeb) return 'Web Browser';
    return 'App';
  }

  /// Get IANA Timezone (matching web's Intl.DateTimeFormat)
  static Future<String> getTimezone() async {
    try {
      // FlutterTimezone.getLocalTimezone() returns timezone string (e.g., "Asia/Riyadh")
      final timezone = await FlutterTimezone.getLocalTimezone();
      return timezone.toString();
    } catch (_) {
      return DateTime.now().timeZoneName;
    }
  }

  /// Generate full device fingerprint matching web project's 'extract-device-info.ts'
  static Future<ResearcherLoginFingerprint> getFingerprint() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // 1. Screen Dimensions (Logical Pixels matching window.screen.width/height)
    final view = ui.PlatformDispatcher.instance.implicitView;
    final double physicalWidth = view?.physicalSize.width ?? 0;
    final double physicalHeight = view?.physicalSize.height ?? 0;

    // 2. Hardware Concurrency (Real cores matching navigator.hardwareConcurrency)
    int hardwareConcurrency = Platform.numberOfProcessors;

    // 3. RAM (GB matching navigator.deviceMemory)
    int ramGB = 0;
    try {
      if (Platform.isAndroid) {
        // On Android, we can get more accurate info from /proc/meminfo
        final memInfo = await File('/proc/meminfo').readAsLines();
        final totalMemLine = memInfo.firstWhere(
          (line) => line.startsWith('MemTotal:'),
        );
        final totalMemKb = int.parse(totalMemLine.split(RegExp(r'\s+'))[1]);
        double rawGB = totalMemKb / (1024 * 1024);

        // Map to actual physical RAM sizes (Marketing numbers)
        // System usually reserves some RAM, so we map up to the nearest common tier
        if (rawGB <= 1) {
          ramGB = 1;
        } else if (rawGB <= 2) {
          ramGB = 2;
        } else if (rawGB <= 3) {
          ramGB = 3;
        } else if (rawGB <= 4) {
          ramGB = 4;
        } else if (rawGB <= 6) {
          ramGB = 6;
        } else if (rawGB <= 8) {
          ramGB = 8;
        } else if (rawGB <= 12) {
          ramGB = 12;
        } else if (rawGB <= 16) {
          ramGB = 16;
        } else {
          ramGB = rawGB.round();
        }
      } else {
        final int? memoryBytes = await SystemInfoPlus.physicalMemory;
        if (memoryBytes != null) {
          // SystemInfoPlus returns bytes
          ramGB = (memoryBytes / (1024 * 1024 * 1024)).ceil();
        }
      }

      // Web's navigator.deviceMemory is usually capped at 8GB and is a power of 2
      // but for "device capabilities" we can show the real value.
    } catch (_) {
      ramGB = 0;
    }

    // 4. Max Touch Points (matching navigator.maxTouchPoints)
    int maxTouchPoints = 5; // Default for modern smartphones
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.systemFeatures.contains(
          'android.hardware.touchscreen.multitouch.jazzhand',
        )) {
          maxTouchPoints = 10;
        } else if (androidInfo.systemFeatures.contains(
          'android.hardware.touchscreen.multitouch.distinct',
        )) {
          maxTouchPoints = 5;
        }
      }
    } catch (_) {}

    // 5. Device Model, Brand & Hardware
    String deviceModel = 'Unknown';
    String deviceBrand = 'Unknown';
    String osVersion = 'Unknown';
    String hardware = 'Unknown';
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceModel = androidInfo.model;
        deviceBrand = androidInfo.brand;
        osVersion = 'Android ${androidInfo.version.release}';
        hardware = androidInfo.hardware; // Returns the actual chipset/board
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        deviceBrand = 'Apple';
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        hardware = 'Apple Silicon';
      }
    } catch (_) {}

    // 6. User Agent (Constructed to match standard formats with device info)
    final String userAgent =
        'SurveySystemApp/${packageInfo.version} ($deviceBrand $deviceModel; $hardware; $osVersion; RAM: ${ramGB}GB; Cores: $hardwareConcurrency)';

    return ResearcherLoginFingerprint(
      user_agent: userAgent,
      screen: ResearcherLoginScreen(
        width: physicalWidth.round(),
        height: physicalHeight.round(),
      ),
      ram: ramGB,
      hardware_concurrency: hardwareConcurrency,
      max_touch_points: maxTouchPoints,
    );
  }
}

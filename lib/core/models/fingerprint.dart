/// Device Fingerprint Model
///
/// Unified model for device fingerprint information used across the app.
/// Used in both authentication (login) and device registration flows.
class Fingerprint {
  // Core fingerprint fields (for API)
  final String user_agent;
  final FingerprintScreen screen;
  final int ram;
  final int hardware_concurrency;
  final int max_touch_points;
  final String device_model;
  final String os_version;

  // Additional fields for UI and device registration
  final String browser;
  final String os;
  final String deviceType;

  const Fingerprint({
    this.user_agent = '',
    this.screen = const FingerprintScreen(),
    this.ram = 0,
    this.hardware_concurrency = 0,
    this.max_touch_points = 0,
    this.device_model = '',
    this.os_version = '',
    this.browser = '',
    this.os = '',
    this.deviceType = '',
  });

  /// Convert to JSON for API requests (only core fingerprint fields)
  Map<String, dynamic> toJson() => {
    'user_agent': user_agent,
    'screen': screen.toJson(),
    'ram': ram,
    'hardware_concurrency': hardware_concurrency,
    'max_touch_points': max_touch_points,
    'device_model': device_model,
    'os_version': os_version,
  };

  /// Get screen width
  int get screenWidth => screen.width;

  /// Get screen height
  int get screenHeight => screen.height;

  /// Get RAM in GB (alias for ram)
  int get ramGB => ram;

  /// Get processor cores (alias for hardware_concurrency)
  int get processorCores => hardware_concurrency;

  /// Get max touch points (alias for max_touch_points)
  int get maxTouchPoints => max_touch_points;
}

/// Screen dimensions model
class FingerprintScreen {
  final int width;
  final int height;

  const FingerprintScreen({this.width = 0, this.height = 0});

  Map<String, dynamic> toJson() => {'width': width, 'height': height};
}

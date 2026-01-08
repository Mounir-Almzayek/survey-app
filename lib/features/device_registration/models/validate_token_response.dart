class ValidateTokenResponse {
  final int id;
  final String token;
  final int physicalDeviceId;
  final DateTime expiresAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PhysicalDevice physicalDevice;
  final PhysicalDeviceAuthentication? physicalDeviceAuthentication;

  const ValidateTokenResponse({
    required this.id,
    required this.token,
    required this.physicalDeviceId,
    required this.expiresAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.physicalDevice,
    this.physicalDeviceAuthentication,
  });

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) {
    return ValidateTokenResponse(
      id: json['id'] as int,
      token: json['token'] as String,
      physicalDeviceId: json['physical_device_id'] as int,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      physicalDevice: PhysicalDevice.fromJson(
        json['physical_device'] as Map<String, dynamic>,
      ),
      physicalDeviceAuthentication:
          json['physical_device_authentication'] != null
          ? PhysicalDeviceAuthentication.fromJson(
              json['physical_device_authentication'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PhysicalDevice {
  final int id;
  final String name;
  final int? zoneId;
  final String type;
  final String status;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const PhysicalDevice({
    required this.id,
    required this.name,
    this.zoneId,
    required this.type,
    required this.status,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory PhysicalDevice.fromJson(Map<String, dynamic> json) {
    return PhysicalDevice(
      id: json['id'] as int,
      name: json['name'] as String,
      zoneId: json['zone_id'] as int?,
      type: json['type'] as String,
      status: json['status'] as String,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }
}

class PhysicalDeviceAuthentication {
  // Add fields based on API response when available
  const PhysicalDeviceAuthentication();

  factory PhysicalDeviceAuthentication.fromJson(Map<String, dynamic> json) {
    return const PhysicalDeviceAuthentication();
  }
}

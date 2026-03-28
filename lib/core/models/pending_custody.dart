/// Pending Custody Model
///
/// Model for pending custody transfer data returned from the second phase of login API.
/// Contains information about device custody transfers between users.
class PendingCustody {
  final int id;
  final int physical_device_id;
  final int? from_user_id;
  final int? to_user_id;
  final String? notes;
  final DateTime? verified_at;
  final DateTime created_at;
  final DateTime updated_at;
  final PhysicalDevice? physical_device;
  final CustodyUser? from_user;
  final CustodyUser? to_user;

  const PendingCustody({
    required this.id,
    required this.physical_device_id,
    this.from_user_id,
    this.to_user_id,
    this.notes,
    this.verified_at,
    required this.created_at,
    required this.updated_at,
    this.physical_device,
    this.from_user,
    this.to_user,
  });

  /// Create from JSON
  factory PendingCustody.fromJson(Map<String, dynamic> json) {
    return PendingCustody(
      id: json['id'] as int,
      physical_device_id: json['physical_device_id'] as int,
      from_user_id: json['from_user_id'] as int?,
      to_user_id: json['to_user_id'] as int?,
      notes: json['notes'] as String?,
      verified_at: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: DateTime.parse(json['updated_at'] as String),
      physical_device: json['physical_device'] != null
          ? PhysicalDevice.fromJson(
              Map<String, dynamic>.from(json['physical_device']),
            )
          : null,
      from_user: json['from_user'] != null
          ? CustodyUser.fromJson(Map<String, dynamic>.from(json['from_user']))
          : null,
      to_user: json['to_user'] != null
          ? CustodyUser.fromJson(Map<String, dynamic>.from(json['to_user']))
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'physical_device_id': physical_device_id,
    'from_user_id': from_user_id,
    'to_user_id': to_user_id,
    'notes': notes,
    'verified_at': verified_at?.toIso8601String(),
    'created_at': created_at.toIso8601String(),
    'updated_at': updated_at.toIso8601String(),
    'physical_device': physical_device?.toJson(),
    'from_user': from_user?.toJson(),
    'to_user': to_user?.toJson(),
  };

  /// Check if custody is verified
  bool get isVerified => verified_at != null;

  /// Check if custody is pending (not verified)
  bool get isPending => verified_at == null;
}

/// Physical Device Model
class PhysicalDevice {
  final int id;
  final String name;
  final String? type;
  final String? status;

  const PhysicalDevice({
    required this.id,
    required this.name,
    this.type,
    this.status,
  });

  /// Create from JSON
  factory PhysicalDevice.fromJson(Map<String, dynamic> json) {
    return PhysicalDevice(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String?,
      status: json['status'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'status': status,
  };
}

/// Custody User Model
class CustodyUser {
  final int id;
  final String? name;
  final String email;

  const CustodyUser({required this.id, this.name, required this.email});

  /// Create from JSON
  factory CustodyUser.fromJson(Map<String, dynamic> json) {
    return CustodyUser(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  /// Get display name (fallback to email if name is null)
  String get displayName => name ?? email;
}

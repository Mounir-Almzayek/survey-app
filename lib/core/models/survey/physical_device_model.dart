import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'assignment_model.dart';

/// PhysicalDevice Model - Complete device management
class PhysicalDevice extends Equatable {
  final int id;
  final String name;
  final String type;
  final PhysicalDeviceStatus status;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations
  final List<PhysicalDeviceZone>? zones;
  final List<Assignment>? assignments;
  final List<PhysicalDeviceLog>? logs;
  final List<PublicLink>? createdPublicLinks;

  const PhysicalDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.zones,
    this.assignments,
    this.logs,
    this.createdPublicLinks,
  });

  factory PhysicalDevice.fromJson(Map<String, dynamic> json) {
    return PhysicalDevice(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: PhysicalDeviceStatus.fromJson(json['status']),
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
      zones: (json['zones'] as List?)
          ?.map((e) => PhysicalDeviceZone.fromJson(e))
          .toList(),
      assignments: (json['assignments'] as List?)
          ?.map((e) => Assignment.fromJson(e))
          .toList(),
      logs: (json['physical_device_logs'] as List?)
          ?.map((e) => PhysicalDeviceLog.fromJson(e))
          .toList(),
      createdPublicLinks: (json['created_public_links'] as List?)
          ?.map((e) => PublicLink.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status.toJson(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'zones': zones?.map((e) => e.toJson()).toList(),
      'assignments': assignments?.map((e) => e.toJson()).toList(),
      'physical_device_logs': logs?.map((e) => e.toJson()).toList(),
      'created_public_links': createdPublicLinks
          ?.map((e) => e.toJson())
          .toList(),
    };
  }

  /// Check if device is active
  bool get isActive => status == PhysicalDeviceStatus.active;

  /// Check if device is pending
  bool get isPending => status == PhysicalDeviceStatus.pending;

  /// Check if device is inactive
  bool get isInactive => status == PhysicalDeviceStatus.inactive;

  /// Check if device is lost
  bool get isLost => status == PhysicalDeviceStatus.lost;

  /// Check if device is online (seen in last 5 minutes)
  bool get isOnline {
    if (lastSeenAt == null) return false;
    return DateTime.now().difference(lastSeenAt!).inMinutes < 5;
  }

  /// Get status description in English
  String get statusDescription {
    switch (status) {
      case PhysicalDeviceStatus.pending:
        return 'Pending';
      case PhysicalDeviceStatus.active:
        return 'Active';
      case PhysicalDeviceStatus.inactive:
        return 'Inactive';
      case PhysicalDeviceStatus.lost:
        return 'Lost';
    }
  }

  /// Get zones count
  int get zonesCount => zones?.length ?? 0;

  /// Get assignments count
  int get assignmentsCount => assignments?.length ?? 0;

  /// Get logs count
  int get logsCount => logs?.length ?? 0;

  /// Check if device has zones
  bool get hasZones => zones != null && zones!.isNotEmpty;

  /// Check if device has assignments
  bool get hasAssignments => assignments != null && assignments!.isNotEmpty;

  /// Check if device has logs
  bool get hasLogs => logs != null && logs!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    status,
    lastSeenAt,
    createdAt,
    updatedAt,
    deletedAt,
    zones,
    assignments,
    logs,
    createdPublicLinks,
  ];
}

/// PhysicalDeviceZone Model - M-to-M relationship between PhysicalDevice and Zone
class PhysicalDeviceZone extends Equatable {
  final int physicalDeviceId;
  final int zoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final PhysicalDevice? physicalDevice;
  final Zone? zone;

  const PhysicalDeviceZone({
    required this.physicalDeviceId,
    required this.zoneId,
    required this.createdAt,
    required this.updatedAt,
    this.physicalDevice,
    this.zone,
  });

  factory PhysicalDeviceZone.fromJson(Map<String, dynamic> json) {
    return PhysicalDeviceZone(
      physicalDeviceId: json['physical_device_id'] as int? ?? 0,
      zoneId: json['zone_id'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      physicalDevice: json['physical_device'] != null
          ? PhysicalDevice.fromJson(json['physical_device'])
          : null,
      zone: json['zone'] != null ? Zone.fromJson(json['zone']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'physical_device_id': physicalDeviceId,
      'zone_id': zoneId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'physical_device': physicalDevice?.toJson(),
      'zone': zone?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    physicalDeviceId,
    zoneId,
    createdAt,
    updatedAt,
    physicalDevice,
    zone,
  ];
}

/// PhysicalDeviceLog Model - Device tracking and logging
class PhysicalDeviceLog extends Equatable {
  final int id;
  final int physicalDeviceId;
  final String logType;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  // Relations
  final PhysicalDevice? physicalDevice;

  const PhysicalDeviceLog({
    required this.id,
    required this.physicalDeviceId,
    required this.logType,
    this.description,
    this.metadata,
    required this.createdAt,
    this.physicalDevice,
  });

  factory PhysicalDeviceLog.fromJson(Map<String, dynamic> json) {
    return PhysicalDeviceLog(
      id: json['id'] as int? ?? 0,
      physicalDeviceId: json['physical_device_id'] as int? ?? 0,
      logType: json['log_type'] as String? ?? '',
      description: json['description'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      physicalDevice: json['physical_device'] != null
          ? PhysicalDevice.fromJson(json['physical_device'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'physical_device_id': physicalDeviceId,
      'log_type': logType,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'physical_device': physicalDevice?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    physicalDeviceId,
    logType,
    description,
    metadata,
    createdAt,
    physicalDevice,
  ];
}

// Forward declarations to avoid circular imports
class PublicLink {
  final int id;
  final String shortCode;

  const PublicLink({required this.id, required this.shortCode});

  factory PublicLink.fromJson(Map<String, dynamic> json) {
    return PublicLink(
      id: json['id'] as int? ?? 0,
      shortCode: json['short_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'short_code': shortCode};
  }
}

class Zone {
  final int id;
  final String name;

  const Zone({required this.id, required this.name});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

import 'package:equatable/equatable.dart';
import 'custody_status.dart';

/// Model representing a custody record
class CustodyRecord extends Equatable {
  final int id;
  final int physicalDeviceId;
  final String physicalDeviceName;
  final String? physicalDeviceType;
  final String? physicalDeviceStatus;
  final int? fromUserId;
  final String? fromUserName;
  final String? fromUserEmail;
  final int? toUserId;
  final String? toUserName;
  final String? toUserEmail;
  final String? verificationCode;
  final DateTime? verifiedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CustodyRecord({
    required this.id,
    required this.physicalDeviceId,
    required this.physicalDeviceName,
    this.physicalDeviceType,
    this.physicalDeviceStatus,
    this.fromUserId,
    this.fromUserName,
    this.fromUserEmail,
    this.toUserId,
    this.toUserName,
    this.toUserEmail,
    this.verificationCode,
    this.verifiedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Create CustodyRecord from JSON
  factory CustodyRecord.fromJson(Map<String, dynamic> json) {
    return CustodyRecord(
      id: json['id'] as int,
      physicalDeviceId: json['physical_device_id'] as int,
      physicalDeviceName:
          json['physical_device']?['name'] as String? ??
          json['physical_device_name'] as String? ??
          '',
      physicalDeviceType: json['physical_device']?['type'] as String?,
      physicalDeviceStatus: json['physical_device']?['status'] as String?,
      fromUserId: json['from_user_id'] as int?,
      fromUserName: json['from_user']?['name'] as String?,
      fromUserEmail: json['from_user']?['email'] as String?,
      toUserId: json['to_user_id'] as int?,
      toUserName: json['to_user']?['name'] as String?,
      toUserEmail: json['to_user']?['email'] as String?,
      verificationCode: json['verification_code'] as String? ?? '',
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'physical_device_id': physicalDeviceId,
      'physical_device_name': physicalDeviceName,
      'physical_device_type': physicalDeviceType,
      'physical_device_status': physicalDeviceStatus,
      'from_user_id': fromUserId,
      'from_user_name': fromUserName,
      'from_user_email': fromUserEmail,
      'to_user_id': toUserId,
      'to_user_name': toUserName,
      'to_user_email': toUserEmail,
      'verification_code': verificationCode,
      'verified_at': verifiedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Get custody status based on verified_at
  CustodyStatus get status {
    if (verifiedAt != null) {
      return CustodyStatus.verified;
    }
    if (deletedAt != null) {
      return CustodyStatus.cancelled;
    }
    return CustodyStatus.pending;
  }

  /// Check if custody is pending
  bool get isPending => status.isPending;

  /// Check if custody is verified
  bool get isVerified => status.isVerified;

  /// Check if custody is cancelled
  bool get isCancelled => status.isCancelled;

  @override
  List<Object?> get props => [
    id,
    physicalDeviceId,
    physicalDeviceName,
    physicalDeviceType,
    physicalDeviceStatus,
    fromUserId,
    fromUserName,
    fromUserEmail,
    toUserId,
    toUserName,
    toUserEmail,
    verificationCode,
    verifiedAt,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

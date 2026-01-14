import 'package:equatable/equatable.dart';

/// Model representing a custody transfer request
class CustodyTransfer extends Equatable {
  final int physicalDeviceId;
  final int toUserId;
  final String? notes;

  const CustodyTransfer({
    required this.physicalDeviceId,
    required this.toUserId,
    this.notes,
  });

  /// Create CustodyTransfer from JSON
  factory CustodyTransfer.fromJson(Map<String, dynamic> json) {
    return CustodyTransfer(
      physicalDeviceId: json['physical_device_id'] as int,
      toUserId: json['to_user_id'] as int,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'physical_device_id': physicalDeviceId,
      'to_user_id': toUserId,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [physicalDeviceId, toUserId, notes];
}

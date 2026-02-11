import 'package:equatable/equatable.dart';
import 'sampling_scope_model.dart';

/// SupervisorZone Model - Supervisor-zone relationships
class SupervisorZone extends Equatable {
  final int id;
  final int supervisorId;
  final int zoneId;
  final DateTime createdAt;

  // Relations
  final Zone? zone;

  const SupervisorZone({
    required this.id,
    required this.supervisorId,
    required this.zoneId,
    required this.createdAt,
    this.zone,
  });

  factory SupervisorZone.fromJson(Map<String, dynamic> json) {
    return SupervisorZone(
      id: json['id'] as int? ?? 0,
      supervisorId: json['supervisor_id'] as int? ?? 0,
      zoneId: json['zone_id'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      zone: json['zone'] != null ? Zone.fromJson(json['zone']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supervisor_id': supervisorId,
      'zone_id': zoneId,
      'created_at': createdAt.toIso8601String(),
      'zone': zone?.toJson(),
    };
  }

  /// Get zone name (convenience getter)
  String get zoneName => zone?.name ?? '';

  /// Check if zone is assigned
  bool get hasZone => zone != null;

  @override
  List<Object?> get props => [id, supervisorId, zoneId, createdAt, zone];
}

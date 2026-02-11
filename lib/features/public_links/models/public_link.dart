import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/models/survey/survey_model.dart';
import '../../../core/styles/app_colors.dart';

/// PublicLinkType enum for different link types
enum PublicLinkType {
  standard,
  shortLived;

  String toJson() => name.toUpperCase();

  static PublicLinkType fromJson(dynamic value) {
    if (value == null) return PublicLinkType.standard;
    final String val = value.toString().toUpperCase();
    return PublicLinkType.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => PublicLinkType.standard,
    );
  }
}

/// Status of a public link
enum PublicLinkStatus {
  active,
  disabled,
  expired;

  String get label {
    switch (this) {
      case PublicLinkStatus.active:
        return 'Active';
      case PublicLinkStatus.disabled:
        return 'Disabled';
      case PublicLinkStatus.expired:
        return 'Expired';
    }
  }

  Color get color {
    switch (this) {
      case PublicLinkStatus.active:
        return AppColors.success;
      case PublicLinkStatus.disabled:
        return AppColors.error;
      case PublicLinkStatus.expired:
        return AppColors.warning;
    }
  }

  IconData get icon {
    switch (this) {
      case PublicLinkStatus.active:
        return Icons.check_circle_outline_rounded;
      case PublicLinkStatus.disabled:
        return Icons.block_flipped;
      case PublicLinkStatus.expired:
        return Icons.history_rounded;
    }
  }

  static PublicLinkStatus fromString(String status, {bool isExpired = false}) {
    if (isExpired) return PublicLinkStatus.expired;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return PublicLinkStatus.active;
      case 'DISABLED':
        return PublicLinkStatus.disabled;
      default:
        return PublicLinkStatus.disabled;
    }
  }

  String toJson() {
    switch (this) {
      case PublicLinkStatus.active:
        return 'ACTIVE';
      case PublicLinkStatus.disabled:
        return 'DISABLED';
      case PublicLinkStatus.expired:
        return 'ACTIVE'; // On server, it's still ACTIVE but logically expired
    }
  }
}

/// Model representing a public link returned from getAll endpoint
class PublicLink extends Equatable {
  final int id;
  final int surveyId;
  final int ownerUserId;
  final String shortCode;
  final PublicLinkStatus status;
  final PublicLinkType type;
  final int maxResponses;
  final int maxResponsesPerIp;
  final bool requireLocation;
  final int? createdByDeviceId;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Survey? survey;

  const PublicLink({
    required this.id,
    required this.surveyId,
    required this.ownerUserId,
    required this.shortCode,
    required this.status,
    this.type = PublicLinkType.standard,
    required this.maxResponses,
    required this.maxResponsesPerIp,
    required this.requireLocation,
    this.createdByDeviceId,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.survey,
  });

  /// Get survey title (convenience getter)
  String get surveyTitle => survey?.title ?? '';

  /// Get full URL (computed from shortCode)
  String get fullUrl =>
      'https://survey-frontend.system2030.com/ar/survey/$shortCode';

  /// Create PublicLink from JSON
  factory PublicLink.fromJson(Map<String, dynamic> json) {
    final expiresAtStr = json['expires_at'] as String?;
    final expiresAt = expiresAtStr != null
        ? DateTime.parse(expiresAtStr)
        : null;
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

    return PublicLink(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int,
      ownerUserId: json['owner_user_id'] as int,
      shortCode: json['short_code'] as String? ?? '',
      status: PublicLinkStatus.fromString(
        json['status'] as String? ?? 'ACTIVE',
        isExpired: isExpired,
      ),
      type: PublicLinkType.fromJson(json['type']),
      maxResponses: json['max_responses'] as int? ?? 0,
      maxResponsesPerIp: json['max_responses_per_ip'] as int? ?? 1,
      requireLocation: json['require_location'] as bool? ?? false,
      createdByDeviceId: json['created_by_device_id'],
      expiresAt: expiresAt,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      survey: json['survey'] != null
          ? Survey.fromJson(json['survey'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'owner_user_id': ownerUserId,
      'short_code': shortCode,
      'status': status.toJson(),
      'type': type.toJson(),
      'max_responses': maxResponses,
      'max_responses_per_ip': maxResponsesPerIp,
      'require_location': requireLocation,
      'created_by_device_id': createdByDeviceId,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'survey': survey?.toJson(),
    };
  }

  /// Check if link is active
  bool get isActive => status == PublicLinkStatus.active;

  /// Check if link is expired
  bool get isExpired => status == PublicLinkStatus.expired;

  /// Check if link is available (active and not expired)
  bool get isAvailable => status == PublicLinkStatus.active;

  @override
  List<Object?> get props => [
    id,
    surveyId,
    ownerUserId,
    shortCode,
    status,
    type,
    maxResponses,
    maxResponsesPerIp,
    requireLocation,
    createdByDeviceId,
    expiresAt,
    createdAt,
    updatedAt,
    survey,
  ];
}

import 'package:equatable/equatable.dart';

/// Model representing a public link
class PublicLink extends Equatable {
  final int id;
  final String shortCode;
  final String fullUrl;
  final int surveyId;
  final String surveyTitle;
  final String status; // ACTIVE, INACTIVE, EXPIRED
  final DateTime? expiresAt;
  final int? maxResponses;
  final int? currentResponses;
  final bool requireLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PublicLink({
    required this.id,
    required this.shortCode,
    required this.fullUrl,
    required this.surveyId,
    required this.surveyTitle,
    required this.status,
    this.expiresAt,
    this.maxResponses,
    this.currentResponses,
    required this.requireLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create PublicLink from JSON
  factory PublicLink.fromJson(Map<String, dynamic> json) {
    return PublicLink(
      id: json['id'] as int,
      shortCode: json['short_code'] as String,
      fullUrl: json['full_url'] as String? ?? '',
      surveyId: json['survey_id'] as int,
      surveyTitle: json['survey_title'] as String? ?? json['survey']?['title'] as String? ?? '',
      status: json['status'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      maxResponses: json['max_responses'] as int?,
      currentResponses: json['current_responses'] as int?,
      requireLocation: json['require_location'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': shortCode,
      'full_url': fullUrl,
      'survey_id': surveyId,
      'survey_title': surveyTitle,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'max_responses': maxResponses,
      'current_responses': currentResponses,
      'require_location': requireLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if link is active
  bool get isActive => status == 'ACTIVE';

  /// Check if link is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if link has reached max responses
  bool get hasReachedMaxResponses {
    if (maxResponses == null) return false;
    if (currentResponses == null) return false;
    return currentResponses! >= maxResponses!;
  }

  /// Check if link is available (active, not expired, not maxed)
  bool get isAvailable => isActive && !isExpired && !hasReachedMaxResponses;

  @override
  List<Object?> get props => [
        id,
        shortCode,
        fullUrl,
        surveyId,
        surveyTitle,
        status,
        expiresAt,
        maxResponses,
        currentResponses,
        requireLocation,
        createdAt,
        updatedAt,
      ];
}


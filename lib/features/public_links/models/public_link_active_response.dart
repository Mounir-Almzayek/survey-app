import 'package:equatable/equatable.dart';

class PublicLinkActiveResponse extends Equatable {
  final String shortCode;
  final int responseId;
  final String surveyTitle;
  final int lastSectionId;
  final int totalSections;
  final DateTime updatedAt;

  const PublicLinkActiveResponse({
    required this.shortCode,
    required this.responseId,
    required this.surveyTitle,
    required this.lastSectionId,
    required this.totalSections,
    required this.updatedAt,
  });

  factory PublicLinkActiveResponse.fromJson(Map<String, dynamic> json) {
    return PublicLinkActiveResponse(
      shortCode: json['short_code'] as String,
      responseId: json['response_id'] as int,
      surveyTitle: json['survey_title'] as String? ?? '',
      lastSectionId: json['last_section_id'] as int,
      totalSections: json['total_sections'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'short_code': shortCode,
      'response_id': responseId,
      'survey_title': surveyTitle,
      'last_section_id': lastSectionId,
      'total_sections': totalSections,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PublicLinkActiveResponse copyWith({
    int? lastSectionId,
    int? totalSections,
    DateTime? updatedAt,
  }) {
    return PublicLinkActiveResponse(
      shortCode: shortCode,
      responseId: responseId,
      surveyTitle: surveyTitle,
      lastSectionId: lastSectionId ?? this.lastSectionId,
      totalSections: totalSections ?? this.totalSections,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (totalSections <= 0) return 0;
    // We assume sections are ordered by ID or appearance. 
    // For a simple stat, we'll use the ratio of sections completed.
    return (lastSectionId / totalSections).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props =>
      [shortCode, responseId, surveyTitle, lastSectionId, totalSections, updatedAt];
}


import 'package:equatable/equatable.dart';

import 'assignment.dart';
import 'section.dart';
import 'survey_status.dart';

/// Survey model matching backend SurveyWithRelations (simplified)
class Survey extends Equatable {
  final int id;
  final int? createdByUserId;
  final String title;
  final String description;
  final SurveyStatus status;
  final DateTime? availabilityStartAt;
  final DateTime? availabilityEndAt;
  final int maxResponses;
  final bool gpsRequired;
  final String lang;
  final int? minimumResponseTimeMinutes;
  final String greetingMessage;
  final String goodbayMessage;
  final String? tagsCsv;
  final DateTime? willPublishAt;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Optional relations when API includes them
  final List<Section> sections;
  final List<Assignment> assignments;

  const Survey({
    required this.id,
    required this.createdByUserId,
    required this.title,
    required this.description,
    required this.status,
    required this.availabilityStartAt,
    required this.availabilityEndAt,
    required this.maxResponses,
    required this.gpsRequired,
    required this.lang,
    required this.minimumResponseTimeMinutes,
    required this.greetingMessage,
    required this.goodbayMessage,
    required this.tagsCsv,
    required this.willPublishAt,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.sections = const [],
    this.assignments = const [],
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'];
    final assignmentsJson = json['assignments'];

    return Survey(
      id: json['id'] as int,
      createdByUserId: json['created_by_user_id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status:
          SurveyStatusX.fromString(json['status'] as String? ?? 'DRAFT'),
      availabilityStartAt: json['availability_start_at'] != null
          ? DateTime.parse(json['availability_start_at'] as String)
          : null,
      availabilityEndAt: json['availability_end_at'] != null
          ? DateTime.parse(json['availability_end_at'] as String)
          : null,
      maxResponses: json['max_responses'] as int? ?? 0,
      gpsRequired: json['gps_required'] as bool? ?? false,
      lang: json['lang'] as String? ?? 'en',
      minimumResponseTimeMinutes:
          json['minimum_response_time_minutes'] as int?,
      greetingMessage: json['greeting_message'] as String? ?? '',
      goodbayMessage: json['goodbay_message'] as String? ?? '',
      tagsCsv: json['tags_csv'] as String?,
      willPublishAt: json['will_publish_at'] != null
          ? DateTime.parse(json['will_publish_at'] as String)
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      sections: sectionsJson is List
          ? sectionsJson
              .map(
                (s) => Section.fromJson(s as Map<String, dynamic>),
              )
              .toList()
          : const [],
      assignments: assignmentsJson is List
          ? assignmentsJson
              .map(
                (a) => Assignment.fromJson(a as Map<String, dynamic>),
              )
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by_user_id': createdByUserId,
      'title': title,
      'description': description,
      'status': status.apiValue,
      'availability_start_at': availabilityStartAt?.toIso8601String(),
      'availability_end_at': availabilityEndAt?.toIso8601String(),
      'max_responses': maxResponses,
      'gps_required': gpsRequired,
      'lang': lang,
      'minimum_response_time_minutes': minimumResponseTimeMinutes,
      'greeting_message': greetingMessage,
      'goodbay_message': goodbayMessage,
      'tags_csv': tagsCsv,
      'will_publish_at': willPublishAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'sections': sections.map((s) => s.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
    };
  }

  bool get isDeleted => deletedAt != null;

  @override
  List<Object?> get props => [
        id,
        createdByUserId,
        title,
        description,
        status,
        availabilityStartAt,
        availabilityEndAt,
        maxResponses,
        gpsRequired,
        lang,
        minimumResponseTimeMinutes,
        greetingMessage,
        goodbayMessage,
        tagsCsv,
        willPublishAt,
        publishedAt,
        createdAt,
        updatedAt,
        deletedAt,
        sections,
        assignments,
      ];
}



import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'section_model.dart';
import 'conditional_logic_model.dart';

class Survey extends Equatable {
  final int id;
  final int? createdByUserId;
  final String title;
  final String description;
  final SurveyStatus status;
  final DateTime? availabilityStartAt;
  final DateTime? availabilityEndAt;
  final int? maxResponses;
  final bool gpsRequired;
  final String lang;
  final int? minimumResponseTimeMinutes;
  final String greetingMessage;
  final String goodbyeMessage;
  final String? tagsCsv;
  final DateTime? willPublishAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<Section>? sections;
  final List<ConditionalLogic>? conditionalLogics;

  const Survey({
    required this.id,
    this.createdByUserId,
    required this.title,
    required this.description,
    this.status = SurveyStatus.draft,
    this.availabilityStartAt,
    this.availabilityEndAt,
    this.maxResponses,
    this.gpsRequired = false,
    required this.lang,
    this.minimumResponseTimeMinutes,
    required this.greetingMessage,
    required this.goodbyeMessage,
    this.tagsCsv,
    this.willPublishAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.sections,
    this.conditionalLogics,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      createdByUserId: json['created_by_user_id'],
      title: json['title'],
      description: json['description'],
      status: SurveyStatus.fromJson(json['status']),
      availabilityStartAt: json['availability_start_at'] != null
          ? DateTime.parse(json['availability_start_at'])
          : null,
      availabilityEndAt: json['availability_end_at'] != null
          ? DateTime.parse(json['availability_end_at'])
          : null,
      maxResponses: json['max_responses'],
      gpsRequired: json['gps_required'] ?? false,
      lang: json['lang'],
      minimumResponseTimeMinutes: json['minimum_response_time_minutes'],
      greetingMessage: json['greeting_message'],
      goodbyeMessage:
          json['goodbay_message'], // Fixed typo from Prisma: goodbay_message
      tagsCsv: json['tags_csv'],
      willPublishAt: json['will_publish_at'] != null
          ? DateTime.parse(json['will_publish_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      sections: (json['sections'] as List?)
          ?.map((e) => Section.fromJson(e))
          .toList(),
      conditionalLogics: (json['conditional_logics'] as List?)
          ?.map((e) => ConditionalLogic.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by_user_id': createdByUserId,
      'title': title,
      'description': description,
      'status': status.toJson(),
      'availability_start_at': availabilityStartAt?.toIso8601String(),
      'availability_end_at': availabilityEndAt?.toIso8601String(),
      'max_responses': maxResponses,
      'gps_required': gpsRequired,
      'lang': lang,
      'minimum_response_time_minutes': minimumResponseTimeMinutes,
      'greeting_message': greetingMessage,
      'goodbay_message': goodbyeMessage,
      'tags_csv': tagsCsv,
      'will_publish_at': willPublishAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'sections': sections?.map((e) => e.toJson()).toList(),
      'conditional_logics': conditionalLogics?.map((e) => e.toJson()).toList(),
    };
  }

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
    goodbyeMessage,
    tagsCsv,
    willPublishAt,
    createdAt,
    updatedAt,
    deletedAt,
    sections,
    conditionalLogics,
  ];
}

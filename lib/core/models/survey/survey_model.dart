import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'section_model.dart';
import 'conditional_logic_model.dart';
import 'report_configuration_model.dart';
import 'assignment_model.dart';

class Survey extends Equatable {
  final int id;
  final int? createdByUserId;
  final String? title;
  final String? description;
  final SurveyStatus? status;
  final DateTime? availabilityStartAt;
  final DateTime? availabilityEndAt;
  final int? maxResponses;
  final bool? gpsRequired;
  final String lang;
  final int? minimumResponseTimeMinutes;
  final int? maxResponseTimeMinutes;
  final String? greetingMessage;
  final String? goodbayMessage;
  final String? tagsCsv;
  final int? samplingScopeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<int>? localResponseIds;

  final List<Section>? sections;
  final List<ConditionalLogic>? conditionalLogics;
  final List<ReportConfiguration>? reportConfigurations;
  final List<Assignment>? assignments;

  const Survey({
    required this.id,
    this.createdByUserId,
    this.title,
    this.description,
    this.status,
    this.availabilityStartAt,
    this.availabilityEndAt,
    this.maxResponses,
    this.gpsRequired,
    required this.lang,
    this.minimumResponseTimeMinutes,
    this.maxResponseTimeMinutes,
    this.greetingMessage,
    this.goodbayMessage,
    this.tagsCsv,
    this.samplingScopeId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.localResponseIds,
    this.sections,
    this.conditionalLogics,
    this.reportConfigurations,
    this.assignments,
  });

  Survey copyWith({
    int? id,
    int? createdByUserId,
    String? title,
    String? description,
    SurveyStatus? status,
    DateTime? availabilityStartAt,
    DateTime? availabilityEndAt,
    int? maxResponses,
    bool? gpsRequired,
    String? lang,
    int? minimumResponseTimeMinutes,
    int? maxResponseTimeMinutes,
    String? greetingMessage,
    String? goodbyeMessage,
    String? tagsCsv,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<int>? localResponseIds,
    List<Section>? sections,
    List<ConditionalLogic>? conditionalLogics,
    List<ReportConfiguration>? reportConfigurations,
    List<Assignment>? assignments,
  }) {
    return Survey(
      id: id ?? this.id,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      availabilityStartAt: availabilityStartAt ?? this.availabilityStartAt,
      availabilityEndAt: availabilityEndAt ?? this.availabilityEndAt,
      maxResponses: maxResponses ?? this.maxResponses,
      gpsRequired: gpsRequired ?? this.gpsRequired,
      lang: lang ?? this.lang,
      minimumResponseTimeMinutes:
          minimumResponseTimeMinutes ?? this.minimumResponseTimeMinutes,
      maxResponseTimeMinutes:
          maxResponseTimeMinutes ?? this.maxResponseTimeMinutes,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      goodbayMessage: goodbayMessage ?? this.goodbayMessage,
      tagsCsv: tagsCsv ?? this.tagsCsv,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localResponseIds: localResponseIds ?? this.localResponseIds,
      sections: sections ?? this.sections,
      conditionalLogics: conditionalLogics ?? this.conditionalLogics,
      reportConfigurations: reportConfigurations ?? this.reportConfigurations,
      assignments: assignments ?? this.assignments,
    );
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] as int? ?? 0,
      createdByUserId: json['created_by_user_id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] != null
          ? SurveyStatus.fromJson(json['status'])
          : null,
      availabilityStartAt: json['availability_start_at'] != null
          ? DateTime.tryParse(json['availability_start_at'] as String)
          : null,
      availabilityEndAt: json['availability_end_at'] != null
          ? DateTime.tryParse(json['availability_end_at'] as String)
          : null,
      maxResponses: json['max_responses'] as int?,
      gpsRequired: json['gps_required'] as bool?,
      lang: json['lang'] as String? ?? 'en',
      minimumResponseTimeMinutes: json['minimum_response_time_minutes'] as int?,
      maxResponseTimeMinutes: json['max_response_time_minutes'] as int?,
      greetingMessage: json['greeting_message'] as String?,
      goodbayMessage: json['goodbay_message'] as String?,
      tagsCsv: json['tags_csv'] as String?,
      samplingScopeId: json['sampling_scope_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'] as String)
          : null,
      localResponseIds: (json['local_response_ids'] as List?)
          ?.map((e) => e as int)
          .toList(),
      sections: (json['sections'] as List?)
          ?.map((e) => Section.fromJson(e))
          .toList(),
      conditionalLogics: (json['conditional_logics'] as List?)
          ?.map((e) => ConditionalLogic.fromJson(e))
          .toList(),
      reportConfigurations: (json['report_configurations'] as List?)
          ?.map((e) => ReportConfiguration.fromJson(e))
          .toList(),
      assignments: (json['assignments'] as List?)
          ?.map((e) => Assignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by_user_id': createdByUserId,
      'title': title,
      'description': description,
      'status': status?.toJson(),
      'availability_start_at': availabilityStartAt?.toIso8601String(),
      'availability_end_at': availabilityEndAt?.toIso8601String(),
      'max_responses': maxResponses,
      'gps_required': gpsRequired,
      'lang': lang,
      'minimum_response_time_minutes': minimumResponseTimeMinutes,
      'max_response_time_minutes': maxResponseTimeMinutes,
      'greeting_message': greetingMessage,
      'goodbay_message': goodbayMessage,
      'tags_csv': tagsCsv,
      'sampling_scope_id': samplingScopeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'local_response_ids': localResponseIds,
      'sections': sections?.map((e) => e.toJson()).toList(),
      'conditional_logics': conditionalLogics?.map((e) => e.toJson()).toList(),
      'report_configurations': reportConfigurations
          ?.map((e) => e.toJson())
          .toList(),
      'assignments': assignments?.map((e) => e.toJson()).toList(),
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
    maxResponseTimeMinutes,
    greetingMessage,
    goodbayMessage,
    tagsCsv,
    createdAt,
    updatedAt,
    deletedAt,
    localResponseIds,
    sections,
    conditionalLogics,
    reportConfigurations,
    assignments,
  ];
}

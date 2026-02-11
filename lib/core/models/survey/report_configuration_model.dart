import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_enums.dart';
import 'survey_model.dart';
import 'report_section_config_model.dart';
import 'generated_report_model.dart';

/// ReportConfiguration Model - Survey reporting configurations
class ReportConfiguration extends Equatable {
  final int id;
  final int surveyId;
  final String title;
  final String? description;
  final ReportSchedule? schedule;
  final bool? isActive;
  final List<ReportFormat>? formats;
  final List<ReportSectionConfig>? sections;
  final List<GeneratedReport>? generatedReports;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Survey? survey;

  const ReportConfiguration({
    required this.id,
    required this.surveyId,
    required this.title,
    this.description,
    this.schedule,
    this.isActive,
    this.formats,
    this.sections,
    this.generatedReports,
    required this.createdAt,
    required this.updatedAt,
    this.survey,
  });

  factory ReportConfiguration.fromJson(Map<String, dynamic> json) {
    return ReportConfiguration(
      id: json['id'] as int? ?? 0,
      surveyId: json['survey_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      schedule: json['schedule'] != null
          ? ReportSchedule.fromJson(json['schedule'])
          : null,
      isActive: json['is_active'] as bool?,
      formats: (json['formats'] as List?)
          ?.map((e) => ReportFormat.fromJson(e))
          .toList(),
      sections: (json['sections'] as List?)
          ?.map((e) => ReportSectionConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedReports: (json['generated_reports'] as List?)
          ?.map((e) => GeneratedReport.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      survey: json['survey'] != null ? Survey.fromJson(json['survey']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'title': title,
      'description': description,
      'schedule': schedule?.toJson(),
      'is_active': isActive,
      'formats': formats?.map((e) => e.toJson()).toList(),
      'sections': sections?.map((e) => e.toJson()).toList(),
      'generated_reports': generatedReports?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'survey': survey?.toJson(),
    };
  }

  /// Check if configuration is active
  bool get isActiveStatus => isActive ?? true;

  /// Get configuration as JSON string
  String get configurationJson => sections?.toString() ?? '{}';

  /// Check if configuration has specific key
  bool hasConfigKey(String key) =>
      false; // Simplified - actual config is in sections

  /// Get configuration value by key
  dynamic getConfigValue(String key) =>
      null; // Simplified - actual config is in sections

  /// Get configuration value by key with default
  T getConfigValueOrDefault<T>(String key, T defaultValue) {
    return defaultValue; // Simplified - actual config is in sections
  }

  @override
  List<Object?> get props => [
    id,
    surveyId,
    title,
    description,
    schedule,
    isActive,
    formats,
    sections,
    generatedReports,
    createdAt,
    updatedAt,
    survey,
  ];
}

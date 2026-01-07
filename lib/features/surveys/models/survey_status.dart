import 'package:equatable/equatable.dart';

/// Survey status enum matching backend SurveyStatusSchema
/// Values: 'DRAFT','PUBLISHED','ARCHIVED'
enum SurveyStatus {
  draft,
  published,
  archived,
}

extension SurveyStatusX on SurveyStatus {
  static SurveyStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return SurveyStatus.draft;
      case 'PUBLISHED':
        return SurveyStatus.published;
      case 'ARCHIVED':
        return SurveyStatus.archived;
      default:
        return SurveyStatus.draft;
    }
  }

  String get apiValue {
    switch (this) {
      case SurveyStatus.draft:
        return 'DRAFT';
      case SurveyStatus.published:
        return 'PUBLISHED';
      case SurveyStatus.archived:
        return 'ARCHIVED';
    }
  }

  bool get isDraft => this == SurveyStatus.draft;
  bool get isPublished => this == SurveyStatus.published;
  bool get isArchived => this == SurveyStatus.archived;
}

/// Lightweight value object for status with helpers, if needed later
class SurveyStatusInfo extends Equatable {
  final SurveyStatus status;

  const SurveyStatusInfo(this.status);

  @override
  List<Object?> get props => [status];
}



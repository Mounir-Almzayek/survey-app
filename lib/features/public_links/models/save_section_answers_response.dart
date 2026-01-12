import 'package:equatable/equatable.dart';
import '../../../core/models/survey/section_model.dart';

/// Response model for saving section answers
/// POST /public-link/{short_code}/responses/{response_id}/sections/{section_id}
///
/// Backend response shape:
/// {
///   "next_section": Section | null,
///   "is_complete": boolean
/// }
class SaveSectionAnswersResponse extends Equatable {
  final Section? nextSection;
  final bool isComplete;

  const SaveSectionAnswersResponse({
    this.nextSection,
    required this.isComplete,
  });

  factory SaveSectionAnswersResponse.fromJson(Map<String, dynamic> json) {
    return SaveSectionAnswersResponse(
      nextSection: json['next_section'] != null
          ? Section.fromJson(json['next_section'] as Map<String, dynamic>)
          : null,
      isComplete: json['is_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'next_section': nextSection?.toJson(), 'is_complete': isComplete};
  }

  @override
  List<Object?> get props => [nextSection, isComplete];
}

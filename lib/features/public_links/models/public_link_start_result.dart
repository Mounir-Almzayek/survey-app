import '../../../core/models/survey/section_model.dart';
import '../../../core/models/survey/conditional_logic_model.dart';

/// Result of POST /public-link/:short_code/start
class PublicLinkStartResult {
  final int responseId;
  final Section firstSection;
  final List<ConditionalLogic> conditionalLogics;

  const PublicLinkStartResult({
    required this.responseId,
    required this.firstSection,
    required this.conditionalLogics,
  });

  factory PublicLinkStartResult.fromJson(Map<String, dynamic> json) {
    return PublicLinkStartResult(
      responseId: json['response_id'] as int,
      firstSection: Section.fromJson(
        json['first_section'] as Map<String, dynamic>,
      ),
      conditionalLogics: (json['conditional_logics'] as List?)
              ?.map(
                (e) => ConditionalLogic.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Result of POST /public-link/:short_code/responses/:response_id/sections/:section_id
class PublicLinkSectionResult {
  final bool isComplete;

  /// Non-null when [isComplete] is false.
  final Section? nextSection;

  /// Non-null when [isComplete] is true.
  final String? status;

  /// May be non-null when [isComplete] is true and the response was rejected.
  final String? rejectionReason;

  const PublicLinkSectionResult({
    required this.isComplete,
    this.nextSection,
    this.status,
    this.rejectionReason,
  });

  factory PublicLinkSectionResult.fromJson(Map<String, dynamic> json) {
    final isComplete = json['is_complete'] as bool? ?? false;
    return PublicLinkSectionResult(
      isComplete: isComplete,
      nextSection: isComplete
          ? null
          : (json['next_section'] != null
              ? Section.fromJson(
                  json['next_section'] as Map<String, dynamic>,
                )
              : null),
      status: isComplete ? json['status'] as String? : null,
      rejectionReason: isComplete ? json['rejection_reason'] as String? : null,
    );
  }
}

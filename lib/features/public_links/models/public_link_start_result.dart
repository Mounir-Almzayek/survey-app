import 'package:equatable/equatable.dart';

import '../../../core/models/survey/conditional_logic_model.dart';
import '../../../core/models/survey/section_model.dart';
import '../../../core/utils/json_parser.dart';

/// Result of `POST /public-link/:short_code/start`.
///
/// Backend `data` shape:
/// ```json
/// {
///   "response_id": number,
///   "first_section": Section | null,
///   "conditional_logics": ConditionalLogic[] | null
/// }
/// ```
///
/// `first_section` is **nullable** — a published survey with no sections
/// will resolve immediately to a completed response. The bloc treats a null
/// first section as completion.
class PublicLinkStartResult extends Equatable {
  final int responseId;
  final Section? firstSection;
  final List<ConditionalLogic> conditionalLogics;

  const PublicLinkStartResult({
    required this.responseId,
    required this.firstSection,
    this.conditionalLogics = const [],
  });

  factory PublicLinkStartResult.fromJson(Map<String, dynamic> json) {
    return PublicLinkStartResult(
      responseId: JsonParser.asInt(json['response_id']),
      firstSection:
          JsonParser.parseObject(json['first_section'], Section.fromJson),
      conditionalLogics: JsonParser.parseList(
        json['conditional_logics'],
        ConditionalLogic.fromJson,
      ),
    );
  }

  @override
  List<Object?> get props => [responseId, firstSection, conditionalLogics];
}

/// Result of
/// `POST /public-link/:short_code/responses/:response_id/sections/:section_id`.
///
/// Backend `data` is one of two shapes depending on completion:
///
/// **Continue:**
/// ```json
/// { "is_complete": false, "next_section": Section }
/// ```
///
/// **Complete:**
/// ```json
/// { "is_complete": true, "status": string, "rejection_reason": string | null }
/// ```
class PublicLinkSectionResult extends Equatable {
  final bool isComplete;

  /// Non-null when [isComplete] is false.
  final Section? nextSection;

  /// Non-null when [isComplete] is true. Common values: `SUBMITTED`,
  /// `REJECTED`, `FLAGGED`.
  final String? status;

  /// Set when the response was rejected by a policy. Backend pipes
  /// multiple reasons with `|`.
  final String? rejectionReason;

  const PublicLinkSectionResult({
    required this.isComplete,
    this.nextSection,
    this.status,
    this.rejectionReason,
  });

  factory PublicLinkSectionResult.fromJson(Map<String, dynamic> json) {
    final isComplete = JsonParser.asBool(json['is_complete']);
    return PublicLinkSectionResult(
      isComplete: isComplete,
      nextSection: isComplete
          ? null
          : JsonParser.parseObject(json['next_section'], Section.fromJson),
      status: isComplete ? JsonParser.asStringOrNull(json['status']) : null,
      rejectionReason: isComplete
          ? JsonParser.asStringOrNull(json['rejection_reason'])
          : null,
    );
  }

  @override
  List<Object?> get props => [isComplete, nextSection, status, rejectionReason];
}

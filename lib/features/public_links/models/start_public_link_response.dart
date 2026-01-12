import 'package:equatable/equatable.dart';
import '../../../core/models/survey/section_model.dart';
import '../../../core/models/survey/conditional_logic_model.dart';

/// Response model for starting a public link response
/// POST /public-link/{short_code}/start
///
/// Backend response shape:
/// {
///   "response_id": number,
///   "first_section": Section,
///   "conditional_logics": ConditionalLogic[]
/// }
class StartPublicLinkResponse extends Equatable {
  final int responseId;
  final Section? firstSection;
  final List<ConditionalLogic> conditionalLogics;

  const StartPublicLinkResponse({
    required this.responseId,
    this.firstSection,
    this.conditionalLogics = const [],
  });

  factory StartPublicLinkResponse.fromJson(Map<String, dynamic> json) {
    return StartPublicLinkResponse(
      responseId: json['response_id'] as int,
      firstSection: json['first_section'] != null
          ? Section.fromJson(json['first_section'] as Map<String, dynamic>)
          : null,
      conditionalLogics:
          (json['conditional_logics'] as List?)
              ?.map((e) => ConditionalLogic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_id': responseId,
      'first_section': firstSection?.toJson(),
      'conditional_logics': conditionalLogics.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [responseId, firstSection, conditionalLogics];
}

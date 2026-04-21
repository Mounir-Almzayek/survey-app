import 'package:equatable/equatable.dart';

import '../../../core/utils/json_parser.dart';

/// Lightweight public-link metadata returned for both:
///
/// - `GET /public-link/:short_code` (unauthenticated, deep-link entry)
/// - `GET /researcher/public-link/:short_code` (authenticated researcher)
///
/// Both endpoints share the same `data.survey` shape — only the wrappers
/// differ. We surface only what the answering UI cares about (titles,
/// greeting/goodbye copy, location requirement).
///
/// Backend `data` shape (both endpoints):
/// ```json
/// {
///   "survey": {
///     "title": string,
///     "description": string,
///     "greeting_message": string | null,
///     "goodbye_message": string | null
///   },
///   "require_location": boolean,
///   "warning": string | undefined
/// }
/// ```
class ValidatedPublicLink extends Equatable {
  final String surveyTitle;
  final String surveyDescription;
  final String greetingMessage;
  final String goodbyeMessage;
  final bool requireLocation;

  /// Optional advisory copy from the backend (e.g. when this device's quota
  /// is approaching the survey limit). Empty when not provided.
  final String warning;

  const ValidatedPublicLink({
    required this.surveyTitle,
    required this.surveyDescription,
    required this.requireLocation,
    this.greetingMessage = '',
    this.goodbyeMessage = '',
    this.warning = '',
  });

  factory ValidatedPublicLink.fromJson(Map<String, dynamic> json) {
    // Defensive: backend has at times returned `survey` as a list under
    // edge-case empty-survey responses. JsonParser.asMap collapses any
    // non-map to an empty map instead of throwing a hard cast error.
    final survey = JsonParser.asMap(json['survey']);

    return ValidatedPublicLink(
      surveyTitle: JsonParser.asString(survey['title']),
      surveyDescription: JsonParser.asString(survey['description']),
      greetingMessage: JsonParser.asString(survey['greeting_message']),
      // Backend has historically used both spellings — accept either.
      goodbyeMessage: JsonParser.asString(
        survey['goodbye_message'] ?? survey['goodbay_message'],
      ),
      requireLocation: JsonParser.asBool(json['require_location']),
      warning: JsonParser.asString(json['warning']),
    );
  }

  Map<String, dynamic> toJson() => {
        'survey': {
          'title': surveyTitle,
          'description': surveyDescription,
          'greeting_message': greetingMessage,
          'goodbye_message': goodbyeMessage,
        },
        'require_location': requireLocation,
        if (warning.isNotEmpty) 'warning': warning,
      };

  @override
  List<Object?> get props => [
        surveyTitle,
        surveyDescription,
        greetingMessage,
        goodbyeMessage,
        requireLocation,
        warning,
      ];
}

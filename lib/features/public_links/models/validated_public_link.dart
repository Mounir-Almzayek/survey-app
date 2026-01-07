import 'package:equatable/equatable.dart';

/// Model representing validated public link data returned for researcher.
///
/// Backend shape (validateAndGetSurvey):
/// {
///   "survey": {
///     "title": string,
///     "description": string,
///     "greeting_message": string
///   },
///   "require_location": boolean
/// }
class ValidatedPublicLink extends Equatable {
  final String surveyTitle;
  final String surveyDescription;
  final String greetingMessage;
  final bool requireLocation;

  const ValidatedPublicLink({
    required this.surveyTitle,
    required this.surveyDescription,
    required this.greetingMessage,
    required this.requireLocation,
  });

  factory ValidatedPublicLink.fromJson(Map<String, dynamic> json) {
    final survey = json['survey'] as Map<String, dynamic>? ?? {};

    return ValidatedPublicLink(
      surveyTitle: survey['title'] as String? ?? '',
      surveyDescription: survey['description'] as String? ?? '',
      greetingMessage: survey['greeting_message'] as String? ?? '',
      requireLocation: json['require_location'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'survey': {
        'title': surveyTitle,
        'description': surveyDescription,
        'greeting_message': greetingMessage,
      },
      'require_location': requireLocation,
    };
  }

  @override
  List<Object?> get props => [
    surveyTitle,
    surveyDescription,
    greetingMessage,
    requireLocation,
  ];
}

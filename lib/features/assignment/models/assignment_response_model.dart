import '../../../core/models/survey/survey_model.dart';

class ListAssignmentsResponse {
  final bool success;
  final String message;
  final List<Survey> surveys;

  ListAssignmentsResponse({
    required this.success,
    required this.message,
    required this.surveys,
  });

  factory ListAssignmentsResponse.fromJson(Map<String, dynamic> json) {
    return ListAssignmentsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      surveys: (json['data'] as List?)
              ?.map((e) => Survey.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GetSurveyAssignmentResponse {
  final bool success;
  final Survey survey;

  GetSurveyAssignmentResponse({
    required this.success,
    required this.survey,
  });

  factory GetSurveyAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return GetSurveyAssignmentResponse(
      success: json['success'] as bool? ?? false,
      survey: Survey.fromJson(json['data']['survey'] as Map<String, dynamic>),
    );
  }
}

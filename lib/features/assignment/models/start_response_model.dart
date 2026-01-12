import '../../../core/models/survey/response_model.dart';

class StartResponseResponse {
  final bool success;
  final String message;
  final Response response;

  StartResponseResponse({
    required this.success,
    required this.message,
    required this.response,
  });

  factory StartResponseResponse.fromJson(Map<String, dynamic> json) {
    return StartResponseResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      response: Response.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

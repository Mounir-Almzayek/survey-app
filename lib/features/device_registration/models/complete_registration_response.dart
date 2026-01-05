class CompleteRegistrationResponse {
  final bool success;
  final String? message;
  final String? errorMessage;
  final String? cookie;

  const CompleteRegistrationResponse({
    required this.success,
    this.message,
    this.errorMessage,
    this.cookie,
  });

  factory CompleteRegistrationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CompleteRegistrationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      errorMessage: json['error_message'] as String? ?? json['errorMessage'] as String?,
      cookie: data?['cookie'] as String?,
    );
  }
}


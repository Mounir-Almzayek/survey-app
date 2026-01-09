class AuthResponse {
  final String accessToken;
  final String userName;
  final List<String> userTypes;

  AuthResponse({
    required this.accessToken,
    required this.userName,
    required this.userTypes,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      userName: json['user_name'] ?? '',
      userTypes: List<String>.from(json['user_types'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'user_name': userName,
      'user_types': userTypes,
    };
  }
}

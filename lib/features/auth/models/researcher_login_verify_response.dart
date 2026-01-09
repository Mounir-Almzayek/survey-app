class ResearcherLoginVerifyResponse {
  final String accessToken;
  final String userName;
  final List<String> userTypes;
  final String? cookie;

  ResearcherLoginVerifyResponse({
    required this.accessToken,
    required this.userName,
    required this.userTypes,
    this.cookie,
  });

  factory ResearcherLoginVerifyResponse.fromJson(Map<String, dynamic> json) {
    // Handle both direct response and wrapped in data
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return ResearcherLoginVerifyResponse(
      accessToken: data['accessToken'] ?? data['access_token'] ?? '',
      userName: data['user_name'] ?? data['name'] ?? '',
      userTypes: List<String>.from(data['user_types'] ?? []),
      cookie: data['cookie'],
    );
  }
}

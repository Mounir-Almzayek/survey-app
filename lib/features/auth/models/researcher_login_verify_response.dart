import '../../profile/models/user.dart';

class ResearcherLoginVerifyResponse {
  final String accessToken;
  final User user;
  final String? cookie;

  ResearcherLoginVerifyResponse({
    required this.accessToken,
    required this.user,
    this.cookie,
  });

  factory ResearcherLoginVerifyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return ResearcherLoginVerifyResponse(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      user: User.fromJson(json['user'] ?? data?['user'] ?? {}),
      cookie: json['cookie'] ?? data?['cookie'],
    );
  }
}

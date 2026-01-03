import '../../profile/models/user.dart';

class ResearcherLoginVerifyResponse {
  final String accessToken;
  final User user;

  ResearcherLoginVerifyResponse({
    required this.accessToken,
    required this.user,
  });

  factory ResearcherLoginVerifyResponse.fromJson(Map<String, dynamic> json) {
    return ResearcherLoginVerifyResponse(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

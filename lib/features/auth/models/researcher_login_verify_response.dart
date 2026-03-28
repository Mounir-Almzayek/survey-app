import '../../../core/models/pending_custody.dart';

class ResearcherLoginVerifyResponse {
  final String accessToken;
  final String userName;
  final List<String> userTypes;
  final String? cookie;
  final bool should_verify_custody;
  final PendingCustody? pending_custody;

  ResearcherLoginVerifyResponse({
    required this.accessToken,
    required this.userName,
    required this.userTypes,
    this.cookie,
    required this.should_verify_custody,
    this.pending_custody,
  });

  factory ResearcherLoginVerifyResponse.fromJson(Map<String, dynamic> json) {
    // Handle both direct response and wrapped in data
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return ResearcherLoginVerifyResponse(
      accessToken: data['accessToken'] ?? data['access_token'] ?? '',
      userName: data['user_name'] ?? data['name'] ?? '',
      userTypes: List<String>.from(data['user_types'] ?? []),
      cookie: data['cookie'],
      should_verify_custody: data['should_verify_custody'] ?? false,
      pending_custody: data['pending_custody'] != null
          ? PendingCustody.fromJson(
              data['pending_custody'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

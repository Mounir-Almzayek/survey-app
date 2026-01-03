import 'researcher_login_base_request.dart';

class ResearcherLoginVerifyRequest extends ResearcherLoginBaseRequest {
  final String deviceToken;
  final String timezone;
  final dynamic credentials; // Changed from String to dynamic

  ResearcherLoginVerifyRequest({
    required super.email,
    required super.password,
    required super.os,
    required super.browser,
    required super.fingerprint,
    required this.deviceToken,
    required this.timezone,
    required this.credentials,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'device_token': deviceToken,
      'timezone': timezone,
      'credentials': credentials,
    });
    return map;
  }
}

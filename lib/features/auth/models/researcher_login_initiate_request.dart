import 'researcher_login_base_request.dart';

class ResearcherLoginInitiateRequest extends ResearcherLoginBaseRequest {
  ResearcherLoginInitiateRequest({
    required super.email,
    required super.password,
    required super.os,
    required super.browser,
    required super.fingerprint,
    required super.deviceToken,
  });
}

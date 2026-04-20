import '../../../data/network/api_request.dart';
import '../models/public_link.dart';
import '../models/public_link_start_result.dart';
import '../models/short_lived_link_result.dart';
import '../models/validated_public_link.dart';

/// Repository for public links online operations
class PublicLinksOnlineRepository {
  /// Get all public links owned by the authenticated researcher
  /// GET /researcher/public-link
  static Future<List<PublicLink>> getMyPublicLinks() async {
    final apiRequest = APIRequest(
      path: '/researcher/public-link',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data
          .map((item) => PublicLink.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Validate a public link by short code
  /// Uses backend route: GET /researcher/public-link/:short_code
  /// and returns lightweight survey info for researcher.
  static Future<ValidatedPublicLink> validatePublicLink(
    String shortCode,
  ) async {
    final apiRequest = APIRequest(
      path: '/researcher/public-link/$shortCode',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    return ValidatedPublicLink.fromJson(data as Map<String, dynamic>);
  }

  /// Public (unauthenticated) survey resolution by short code.
  /// Used by the deep-link flow: GET /public-link/:short_code
  static Future<ValidatedPublicLink> getPublicSurveyByShortCode(
    String shortCode,
  ) async {
    final apiRequest = APIRequest(
      path: '/public-link/$shortCode',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.unauthorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return ValidatedPublicLink.fromJson(data as Map<String, dynamic>);
  }

  /// Start a public-link response (unauthenticated).
  /// POST /public-link/:short_code/start
  /// Returns [responseId], the [firstSection], and [conditionalLogics].
  static Future<PublicLinkStartResult> startPublicLinkResponse({
    required String shortCode,
    required String gender,
    required String ageGroup,
    ({double latitude, double longitude})? location,
  }) async {
    final body = <String, dynamic>{
      'gender': gender,
      'age_group': ageGroup,
      if (location != null)
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
    };

    final apiRequest = APIRequest(
      path: '/public-link/$shortCode/start',
      method: HTTPMethod.post,
      body: body,
      authorizationOption: AuthorizationOption.unauthorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return PublicLinkStartResult.fromJson(data as Map<String, dynamic>);
  }

  /// Submit answers for one section and retrieve the next section or a
  /// completion signal (unauthenticated).
  /// POST /public-link/:short_code/responses/:response_id/sections/:section_id
  static Future<PublicLinkSectionResult> submitPublicLinkSection({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required List<({int questionId, dynamic value})> answers,
  }) async {
    final body = <String, dynamic>{
      'answers': answers
          .map((a) => {'question_id': a.questionId, 'value': a.value})
          .toList(),
    };

    final apiRequest = APIRequest(
      path: '/public-link/$shortCode/responses/$responseId/sections/$sectionId',
      method: HTTPMethod.post,
      body: body,
      authorizationOption: AuthorizationOption.unauthorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return PublicLinkSectionResult.fromJson(data as Map<String, dynamic>);
  }

  /// Create a short-lived public link for proxy location capture.
  /// POST /researcher/public-link/short-lived
  /// [body] is typically [CreateShortLivedLinkRequest.toJson] (`survey_id` only).
  static Future<ShortLivedLinkResult> createShortLived({
    required Map<String, dynamic> body,
  }) async {
    final apiRequest = APIRequest(
      path: '/researcher/public-link/short-lived',
      method: HTTPMethod.post,
      body: body,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return ShortLivedLinkResult.fromJson(data as Map<String, dynamic>);
  }
}

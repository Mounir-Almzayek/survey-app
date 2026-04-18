import '../../../data/network/api_request.dart';
import '../models/public_link.dart';
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

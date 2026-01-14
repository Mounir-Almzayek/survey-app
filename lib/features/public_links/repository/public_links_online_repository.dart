import '../../../data/network/api_request.dart';
import '../models/public_link.dart';
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
}

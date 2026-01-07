import '../../../data/network/api_request.dart';
import '../models/validated_public_link.dart';

/// Repository for public links online operations
/// Each method should have its own bloc
class PublicLinksOnlineRepository {
  /// Validate a public link by short code
  /// Uses backend route: GET /researcher/public-link/:short_code
  /// and returns lightweight survey info for researcher.
  static Future<ValidatedPublicLink> validatePublicLink(
    String shortCode,
  ) async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/public-link/$shortCode',
        method: HTTPMethod.get,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;

      return ValidatedPublicLink.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to validate public link: ${e.toString()}');
    }
  }
}

import '../../../data/network/api_request.dart';
import '../models/public_link.dart';

/// Repository for public links online operations
/// Each method should have its own bloc
class PublicLinksOnlineRepository {
  /// Get list of public links for researcher
  /// This method should use LoadPublicLinksBloc
  static Future<List<PublicLink>> getPublicLinks() async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/public-link',
        method: HTTPMethod.get,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;
      
      if (data is List) {
        return data.map((item) => PublicLink.fromJson(item as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load public links: ${e.toString()}');
    }
  }

  /// Validate a public link by short code
  /// This method should use ValidatePublicLinkBloc
  static Future<PublicLink> validatePublicLink(String shortCode) async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/public-link/$shortCode',
        method: HTTPMethod.get,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;
      
      return PublicLink.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to validate public link: ${e.toString()}');
    }
  }
}


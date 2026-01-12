import '../../../data/network/api_request.dart';
import '../models/public_link.dart';
import '../models/validated_public_link.dart';
import '../models/start_public_link_request.dart';
import '../models/start_public_link_response.dart';
import '../models/save_section_answers_request.dart';
import '../models/save_section_answers_response.dart';

/// Repository for public links online operations
/// Each method should have its own bloc
class PublicLinksOnlineRepository {
  /// Visit public link by short code (public route - no authentication)
  /// GET /public-link/:short_code
  /// Returns validated public link data including survey info
  static Future<ValidatedPublicLink> visitPublicLink(String shortCode) async {
    final apiRequest = APIRequest(
      path: '/public-link/$shortCode',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.unauthorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    return ValidatedPublicLink.fromJson(data as Map<String, dynamic>);
  }

  /// Start a new response via public link
  /// POST /public-link/:short_code/start
  /// Returns response_id, first_section, and conditional_logics
  static Future<StartPublicLinkResponse> startPublicLinkResponse(
    String shortCode, {
    StartPublicLinkRequest? request,
  }) async {
    final apiRequest = APIRequest(
      path: '/public-link/$shortCode/start',
      method: HTTPMethod.post,
      authorizationOption: AuthorizationOption.unauthorized,
      body: request?.toJson() ?? {},
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    return StartPublicLinkResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Get the APIRequest for saving section answers (without sending)
  static APIRequest getSaveSectionAnswersRequest({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required SaveSectionAnswersRequest request,
  }) {
    return APIRequest(
      path: '/public-link/$shortCode/responses/$responseId/sections/$sectionId',
      method: HTTPMethod.post,
      authorizationOption: AuthorizationOption.unauthorized,
      body: request.toJson(),
    );
  }

  /// Save section answers for a public link response
  /// POST /public-link/:short_code/responses/:response_id/sections/:section_id
  /// Returns next_section (if any) and is_complete flag
  static Future<SaveSectionAnswersResponse> saveSectionAnswers({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required SaveSectionAnswersRequest request,
  }) async {
    final apiRequest = getSaveSectionAnswersRequest(
      shortCode: shortCode,
      responseId: responseId,
      sectionId: sectionId,
      request: request,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    return SaveSectionAnswersResponse.fromJson(data as Map<String, dynamic>);
  }

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

  /// Validate a public link by short code (existing method)
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

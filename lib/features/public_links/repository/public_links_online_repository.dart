import 'package:flutter/foundation.dart' show visibleForTesting;

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
  ///
  /// As of the QuotaTarget migration the body no longer carries gender or
  /// age group; quota matching happens server-side at FINAL_SUBMIT.
  static Future<PublicLinkStartResult> startPublicLinkResponse({
    required String shortCode,
    ({double latitude, double longitude})? location,
  }) async {
    final body = buildStartBody(location: location);

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

  /// Build the request body for the public-link start endpoint. The
  /// `created_at` field is captured at call time so the server can record
  /// the moment of user action even when the request is replayed later.
  @visibleForTesting
  static Map<String, dynamic> buildStartBody({
    ({double latitude, double longitude})? location,
    DateTime? createdAt,
  }) {
    final ts = (createdAt ?? DateTime.now()).toUtc().toIso8601String();
    return <String, dynamic>{
      if (location != null)
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      'created_at': ts,
    };
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
    final body = buildSectionSubmitBody(answers: answers);

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

  /// Build the request body for the public-link section-submit endpoint.
  /// `created_at` is captured at call time. See [buildStartBody] for
  /// backend-compatibility notes.
  @visibleForTesting
  static Map<String, dynamic> buildSectionSubmitBody({
    required List<({int questionId, dynamic value})> answers,
    DateTime? createdAt,
  }) {
    final ts = (createdAt ?? DateTime.now()).toUtc().toIso8601String();
    return <String, dynamic>{
      'answers': answers
          .map((a) => {'question_id': a.questionId, 'value': a.value})
          .toList(),
      'created_at': ts,
    };
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

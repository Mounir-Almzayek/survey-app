import '../../../data/network/api_request.dart';
import '../models/response.dart';
import '../models/response_details.dart';

/// Online repository for responses.
class ResponsesOnlineRepository {
  /// Get paginated responses for a specific survey (admin API reused).
  /// GET /admin/response?schedule_id={surveyId}
  static Future<List<ResponseSummary>> getSurveyResponses({
    required int surveyId,
    int? page,
  }) async {
    final apiRequest = APIRequest(
      path: '/admin/response',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
      query: {
        'survey_id': surveyId.toString(),
        if (page != null) 'page': page.toString(),
      },
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data
          .map((item) => ResponseSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get detailed response by ID.
  /// GET /researcher/response/{id}/details
  static Future<ResponseDetails> getResponseDetails(int id) async {
    final apiRequest = APIRequest(
      path: '/researcher/response/$id/details',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    return ResponseDetails.fromJson(data as Map<String, dynamic>);
  }
}

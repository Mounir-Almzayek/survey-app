import '../../../data/network/api_request.dart';
import '../models/survey.dart';

/// Online repository for surveys for the researcher app.
class SurveysOnlineRepository {
  /// Get survey details by ID (including sections & questions where available).
  /// Reuses the admin survey shape, but called from researcher context.
  static Future<Survey> getSurveyDetails(int id) async {
    final apiRequest = APIRequest(
      path: '/admin/survey/$id',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    return Survey.fromJson(data as Map<String, dynamic>);
  }

  /// Get list of surveys assigned to the current user (Researcher).
  /// Endpoint: /my-surveys (Assumed standard for researcher context)
  static Future<List<Survey>> getAssignedSurveys() async {
    final apiRequest = APIRequest(
      path: '/my-surveys',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data
          .map((e) => Survey.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

import '../../../data/network/api_request.dart';
import '../models/assignment.dart';
import '../models/survey.dart';

/// Online repository for surveys & assignments for the researcher app.
///
/// NOTE: Some researcher APIs are not implemented yet on backend.
/// This repository follows the planned API shapes documented in
/// `docs/APP_ARCHITECTURE.md` and existing admin routes.
class SurveysOnlineRepository {
  /// Get list of assignments for the current researcher.
  /// Planned endpoint: GET /researcher/assignments
  /// Expected shape: list of assignments with nested survey summary.
  static Future<List<Assignment>> getResearcherAssignments() async {
    final apiRequest = APIRequest(
      path: '/researcher/assignments',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data
          .map(
            (item) => Assignment.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  /// Get survey details by ID (including sections & questions where available).
  /// Reuses the admin survey shape, but called from researcher context.
  /// Planned endpoint (for researcher): GET /researcher/surveys/{id}
  /// For now, it can target /admin/survey/{id} when needed.
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
}



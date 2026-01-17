import '../../../data/network/api_request.dart';
import '../models/response_details.dart';

/// Online repository for responses.
class ResponsesOnlineRepository {
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

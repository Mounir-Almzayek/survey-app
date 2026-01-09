import '../../../data/network/api_request.dart';
import '../models/location_update_request.dart';

/// Repository for updating device location on the server
class DeviceLocationOnlineRepository {
  /// Update device location
  ///
  /// Parameters:
  /// - [deviceId]: The device ID
  /// - [request]: Location update request with latitude, longitude, and optional assignment_id
  ///
  /// Returns: Future that completes when location is updated
  /// Throws: Exception if update fails
  static Future<void> updateDeviceLocation({
    required int deviceId,
    required LocationUpdateRequest request,
  }) async {
    final apiRequest = APIRequest(
      path: '/researcher/device-location/devices/$deviceId/location',
      method: HTTPMethod.post,
      body: request.toJson(),
      authorizationOption: AuthorizationOption.authorized,
    );

    await apiRequest.send();
  }
}

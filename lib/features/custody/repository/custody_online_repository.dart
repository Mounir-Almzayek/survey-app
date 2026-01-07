import '../../../data/network/api_request.dart';
import '../models/custody_record.dart';
import '../models/custody_transfer.dart';

/// Repository for custody online operations
/// Each method should have its own bloc
class CustodyOnlineRepository {
  /// Get list of custody records for researcher
  /// This method should use CustodyListBloc
  static Future<List<CustodyRecord>> getCustodyRecords() async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/custody',
        method: HTTPMethod.get,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;

      if (data is List) {
        return data
            .map((item) =>
                CustodyRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load custody records: ${e.toString()}');
    }
  }

  /// Get custody record by ID
  /// This method should use CustodyListBloc
  static Future<CustodyRecord> getCustodyRecordById(int id) async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/custody/$id',
        method: HTTPMethod.get,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;

      return CustodyRecord.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load custody record: ${e.toString()}');
    }
  }

  /// Create a new custody transfer
  /// This method should use CustodyTransferBloc
  static Future<CustodyRecord> createCustodyTransfer(
    CustodyTransfer transfer,
  ) async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/custody',
        method: HTTPMethod.post,
        body: transfer.toJson(),
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;

      return CustodyRecord.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create custody transfer: ${e.toString()}');
    }
  }

  /// Verify custody with verification code
  /// This method should use CustodyVerificationBloc
  static Future<CustodyRecord> verifyCustody({
    required int id,
    required String verificationCode,
    String? notes,
  }) async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/custody/$id/verify',
        method: HTTPMethod.post,
        body: {
          'verification_code': verificationCode,
          if (notes != null) 'notes': notes,
        },
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;

      return CustodyRecord.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to verify custody: ${e.toString()}');
    }
  }

  /// Resend verification code
  /// This method should use CustodyVerificationBloc
  static Future<CustodyRecord> resendVerificationCode(int id) async {
    try {
      final apiRequest = APIRequest(
        path: '/researcher/custody/$id/resend-code',
        method: HTTPMethod.post,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();
      final data = response.data['data'] ?? response.data;

      return CustodyRecord.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to resend verification code: ${e.toString()}');
    }
  }
}


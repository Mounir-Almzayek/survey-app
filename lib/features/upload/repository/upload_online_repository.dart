import 'package:dio/dio.dart';
import '../../../data/network/api_request.dart';
import '../models/upload_file.dart';

/// Repository for uploading files to the server
class UploadOnlineRepository {
  /// Upload a single image
  static Future<String> uploadImage({
    required UploadFile file,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.file.path,
          filename: file.fileName ?? file.file.name,
        ),
      });

      final apiRequest = APIRequest(
        path: '/upload/image',
        method: HTTPMethod.post,
        body: formData,
        bodyType: BodyType.formData,
        authorizationOption: AuthorizationOption.authorized,
      );

      // Handle progress if callback provided
      if (onProgress != null) {
        // Note: APIRequest doesn't support progress callback directly
        // This would need to be implemented using Dio directly
        // For now, we'll use the standard APIRequest
      }

      final response = await apiRequest.send();

      // Extract URL from response
      final data = response.data['data'] ?? response.data;
      return data['url'] ?? data['imageUrl'] ?? '';
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Upload a single file
  static Future<String> uploadFile({
    required UploadFile file,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.file.path,
          filename: file.fileName ?? file.file.name,
        ),
      });

      final apiRequest = APIRequest(
        path: '/upload/files',
        method: HTTPMethod.post,
        body: formData,
        bodyType: BodyType.formData,
        authorizationOption: AuthorizationOption.authorized,
      );

      final response = await apiRequest.send();

      // Extract URL from response
      final data = response.data['data'] ?? response.data;
      return data['url'] ?? data['fileUrl'] ?? '';
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  /// Upload multiple images
  static Future<List<String>> uploadMultipleImages({
    required List<UploadFile> files,
    Function(int index, int sent, int total)? onProgress,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final url = await uploadImage(
        file: file,
        onProgress: onProgress != null
            ? (sent, total) => onProgress(i, sent, total)
            : null,
      );
      urls.add(url);
    }

    return urls;
  }

  /// Upload multiple files
  static Future<List<String>> uploadMultipleFiles({
    required List<UploadFile> files,
    Function(int index, int sent, int total)? onProgress,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final url = await uploadFile(
        file: file,
        onProgress: onProgress != null
            ? (sent, total) => onProgress(i, sent, total)
            : null,
      );
      urls.add(url);
    }

    return urls;
  }
}

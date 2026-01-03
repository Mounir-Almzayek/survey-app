import 'package:dio/dio.dart';
import '../../../data/network/dio_provider.dart';

/// File Downloader Repository
/// Handles file download operations
class FileDownloaderRepository {
  const FileDownloaderRepository._();

  /// Download file from URL
  static Future<void> downloadFile(
    String url,
    String savePath, {
    Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    await DioProvider.instance.downloadFile(
      url,
      savePath,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );
  }
}

import 'package:dio/dio.dart';
import '../../../data/network/dio_provider.dart';

/// Image Downloader Repository
/// Handles image download operations
class ImageDownloaderRepository {
  const ImageDownloaderRepository._();

  /// Download image from URL
  static Future<void> downloadImage(
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

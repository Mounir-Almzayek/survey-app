import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_helper.dart';
import '../../repository/image_downloader_repository.dart';

part 'image_download_event.dart';
part 'image_download_state.dart';

/// Image Download BLoC
/// Manages image download state and business logic
class ImageDownloadBloc extends Bloc<ImageDownloadEvent, ImageDownloadState> {
  CancelToken? _cancelToken;

  ImageDownloadBloc() : super(const ImageDownloadInitial()) {
    on<ImageDownloadStarted>(_onImageDownloadStarted);
    on<ImageDownloadCancelled>(_onImageDownloadCancelled);
  }

  Future<void> _onImageDownloadStarted(
    ImageDownloadStarted event,
    Emitter<ImageDownloadState> emit,
  ) async {
    // Cancel any existing download
    _cancelToken?.cancel();

    // Create new cancel token for this download
    _cancelToken = CancelToken();

    emit(const ImageDownloadLoading());

    try {
      await ImageDownloaderRepository.downloadImage(
        event.url,
        event.savePath,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          // Only emit progress if not cancelled
          if (!(_cancelToken?.isCancelled ?? true)) {
            emit(ImageDownloadProgress(received: received, total: total));
          }
        },
      );

      // Only emit success if not cancelled
      if (!(_cancelToken?.isCancelled ?? true)) {
        emit(ImageDownloadSuccess(path: event.savePath));
      }
    } on DioException catch (e) {
      // Handle cancellation separately
      if (e.type == DioExceptionType.cancel) {
        emit(const ImageDownloadInitial());
      } else {
        emit(ImageDownloadError(message: ErrorHelper.getErrorMessage(e)));
      }
    } catch (e) {
      // Only emit error if not cancelled
      if (!(_cancelToken?.isCancelled ?? true)) {
        emit(ImageDownloadError(message: ErrorHelper.getErrorMessage(e)));
      }
    } finally {
      _cancelToken = null;
    }
  }

  void _onImageDownloadCancelled(
    ImageDownloadCancelled event,
    Emitter<ImageDownloadState> emit,
  ) {
    // Cancel the active download
    _cancelToken?.cancel();
    _cancelToken = null;
    emit(const ImageDownloadInitial());
  }

  @override
  Future<void> close() {
    // Cancel any active download when BLoC is closed
    _cancelToken?.cancel();
    return super.close();
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_helper.dart';
import '../../repository/file_downloader_repository.dart';

part 'file_download_event.dart';
part 'file_download_state.dart';

/// File Download BLoC
/// Manages file download state and business logic
class FileDownloadBloc extends Bloc<FileDownloadEvent, FileDownloadState> {
  CancelToken? _cancelToken;

  FileDownloadBloc() : super(const FileDownloadInitial()) {
    on<FileDownloadStarted>(_onFileDownloadStarted);
    on<FileDownloadCancelled>(_onFileDownloadCancelled);
  }

  Future<void> _onFileDownloadStarted(
    FileDownloadStarted event,
    Emitter<FileDownloadState> emit,
  ) async {
    // Cancel any existing download
    _cancelToken?.cancel();

    // Create new cancel token for this download
    _cancelToken = CancelToken();

    emit(const FileDownloadLoading());
    try {
      await FileDownloaderRepository.downloadFile(
        event.url,
        event.savePath,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          // Only emit progress if not cancelled
          if (!(_cancelToken?.isCancelled ?? true)) {
            emit(FileDownloadProgress(received: received, total: total));
          }
        },
      );

      // Only emit success if not cancelled
      if (!(_cancelToken?.isCancelled ?? true)) {
        emit(FileDownloadSuccess(path: event.savePath));
      }
    } on DioException catch (e) {
      // Handle cancellation separately
      if (e.type == DioExceptionType.cancel) {
        emit(const FileDownloadInitial());
      } else {
        emit(FileDownloadError(message: ErrorHelper.getErrorMessage(e)));
      }
    } catch (e) {
      // Only emit error if not cancelled
      if (!(_cancelToken?.isCancelled ?? true)) {
        emit(FileDownloadError(message: ErrorHelper.getErrorMessage(e)));
      }
    } finally {
      _cancelToken = null;
    }
  }

  void _onFileDownloadCancelled(
    FileDownloadCancelled event,
    Emitter<FileDownloadState> emit,
  ) {
    // Cancel the active download
    _cancelToken?.cancel();
    _cancelToken = null;
    emit(const FileDownloadInitial());
  }

  @override
  Future<void> close() {
    // Cancel any active download when BLoC is closed
    _cancelToken?.cancel();
    return super.close();
  }
}

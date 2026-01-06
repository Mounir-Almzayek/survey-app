import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/upload_progress.dart';
import '../../repository/upload_online_repository.dart';
import '../../repository/upload_local_repository.dart';
import '../../service/file_picker_service.dart';
import 'upload_event.dart';
import 'upload_state.dart';

/// Bloc for managing file uploads
class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final AsyncRunner<String> _uploadImageRunner = AsyncRunner<String>();
  final AsyncRunner<String> _uploadFileRunner = AsyncRunner<String>();
  final AsyncRunner<List<String>> _uploadMultipleImagesRunner =
      AsyncRunner<List<String>>();
  final AsyncRunner<List<String>> _uploadMultipleFilesRunner =
      AsyncRunner<List<String>>();

  UploadBloc() : super(const UploadInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<PickMultipleImagesEvent>(_onPickMultipleImages);
    on<PickFileEvent>(_onPickFile);
    on<PickMultipleFilesEvent>(_onPickMultipleFiles);
    on<UploadImageEvent>(_onUploadImage);
    on<UploadFileEvent>(_onUploadFile);
    on<UploadMultipleImagesEvent>(_onUploadMultipleImages);
    on<UploadMultipleFilesEvent>(_onUploadMultipleFiles);
    on<CancelUploadEvent>(_onCancelUpload);
    on<RetryUploadEvent>(_onRetryUpload);
    on<ClearUploadsEvent>(_onClearUploads);
    on<RemoveUploadedFileEvent>(_onRemoveUploadedFile);
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(const UploadPicking());

    try {
      final file = await FilePickerService.pickImage(
        source: event.source,
        maxWidth: event.maxWidth,
        maxHeight: event.maxHeight,
        imageQuality: event.imageQuality,
      );

      if (file != null) {
        emit(UploadFilePicked(file: file));
      } else {
        emit(const UploadInitial());
      }
    } catch (e) {
      emit(UploadError(message: e.toString()));
    }
  }

  Future<void> _onPickMultipleImages(
    PickMultipleImagesEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(const UploadPicking());

    try {
      final files = await FilePickerService.pickMultipleImages(
        maxWidth: event.maxWidth,
        maxHeight: event.maxHeight,
        imageQuality: event.imageQuality,
      );

      if (files.isNotEmpty) {
        emit(UploadFilePicked(file: files.first, multipleFiles: files));
      } else {
        emit(const UploadInitial());
      }
    } catch (e) {
      emit(UploadError(message: e.toString()));
    }
  }

  Future<void> _onPickFile(
    PickFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(const UploadPicking());

    try {
      final file = await FilePickerService.pickFile(
        allowedExtensions: event.allowedExtensions,
        type: event.type,
      );

      if (file != null) {
        emit(UploadFilePicked(file: file));
      } else {
        emit(const UploadInitial());
      }
    } catch (e) {
      emit(UploadError(message: e.toString()));
    }
  }

  Future<void> _onPickMultipleFiles(
    PickMultipleFilesEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(const UploadPicking());

    try {
      final files = await FilePickerService.pickMultipleFiles(
        allowedExtensions: event.allowedExtensions,
        type: event.type,
      );

      if (files.isNotEmpty) {
        emit(UploadFilePicked(file: files.first, multipleFiles: files));
      } else {
        emit(const UploadInitial());
      }
    } catch (e) {
      emit(UploadError(message: e.toString()));
    }
  }

  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<UploadState> emit,
  ) async {
    final progress = UploadProgress(
      uploadId: event.file.id,
      file: event.file,
      status: UploadStatus.uploading,
      progress: 0.0,
    );

    emit(UploadUploading(progress: progress));

    await _uploadImageRunner.run(
      onlineTask: (_) async {
        // Save to local storage for offline support
        await UploadLocalRepository.savePendingUpload(progress);

        final url = await UploadOnlineRepository.uploadImage(
          file: event.file,
          onProgress: (sent, total) {
            final newProgress = progress.copyWith(progress: sent / total);
            if (!emit.isDone) {
              emit(UploadUploading(progress: newProgress));
            }
          },
        );

        return url;
      },
      offlineTask: (_) async {
        // Save to local storage for offline support
        await UploadLocalRepository.savePendingUpload(progress);
        throw Exception('No internet connection');
      },
      checkConnectivity: true,
      onStart: () {
        if (!emit.isDone) {
          emit(UploadUploading(progress: progress));
        }
      },
      onSuccess: (url) async {
        final completedProgress = progress.copyWith(
          status: UploadStatus.completed,
          uploadedUrl: url,
          progress: 1.0,
          completedAt: DateTime.now(),
        );

        // Remove from pending
        await UploadLocalRepository.removePendingUpload(event.file.id);

        if (!emit.isDone) {
          emit(UploadCompleted(progress: completedProgress, uploadedUrl: url));
        }
      },
      onError: (error) async {
        final failedProgress = progress.copyWith(
          status: UploadStatus.failed,
          error: error.toString(),
        );

        // Save to failed uploads
        await UploadLocalRepository.saveFailedUpload(failedProgress);
        await UploadLocalRepository.removePendingUpload(event.file.id);

        if (!emit.isDone) {
          emit(UploadFailed(progress: failedProgress, error: error.toString()));
        }
      },
      onCancel: () {
        if (!emit.isDone) {
          emit(UploadCancelled(uploadId: event.file.id));
        }
      },
    );
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    final progress = UploadProgress(
      uploadId: event.file.id,
      file: event.file,
      status: UploadStatus.uploading,
      progress: 0.0,
    );

    emit(UploadUploading(progress: progress));

    await _uploadFileRunner.run(
      onlineTask: (_) async {
        await UploadLocalRepository.savePendingUpload(progress);

        final url = await UploadOnlineRepository.uploadFile(
          file: event.file,
          onProgress: (sent, total) {
            final newProgress = progress.copyWith(progress: sent / total);
            if (!emit.isDone) {
              emit(UploadUploading(progress: newProgress));
            }
          },
        );

        return url;
      },
      offlineTask: (_) async {
        await UploadLocalRepository.savePendingUpload(progress);
        throw Exception('No internet connection');
      },
      checkConnectivity: true,
      onStart: () {
        if (!emit.isDone) {
          emit(UploadUploading(progress: progress));
        }
      },
      onSuccess: (url) async {
        final completedProgress = progress.copyWith(
          status: UploadStatus.completed,
          uploadedUrl: url,
          progress: 1.0,
          completedAt: DateTime.now(),
        );

        await UploadLocalRepository.removePendingUpload(event.file.id);

        if (!emit.isDone) {
          emit(UploadCompleted(progress: completedProgress, uploadedUrl: url));
        }
      },
      onError: (error) async {
        final failedProgress = progress.copyWith(
          status: UploadStatus.failed,
          error: error.toString(),
        );

        await UploadLocalRepository.saveFailedUpload(failedProgress);
        await UploadLocalRepository.removePendingUpload(event.file.id);

        if (!emit.isDone) {
          emit(UploadFailed(progress: failedProgress, error: error.toString()));
        }
      },
      onCancel: () {
        if (!emit.isDone) {
          emit(UploadCancelled(uploadId: event.file.id));
        }
      },
    );
  }

  Future<void> _onUploadMultipleImages(
    UploadMultipleImagesEvent event,
    Emitter<UploadState> emit,
  ) async {
    await _uploadMultipleImagesRunner.run(
      onlineTask: (_) async {
        return await UploadOnlineRepository.uploadMultipleImages(
          files: event.files,
          onProgress: (index, sent, total) {
            // Handle progress for each file
          },
        );
      },
      checkConnectivity: true,
      onSuccess: (urls) {
        if (!emit.isDone) {
          emit(UploadMultipleCompleted(uploadedUrls: urls));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(UploadError(message: error.toString()));
        }
      },
    );
  }

  Future<void> _onUploadMultipleFiles(
    UploadMultipleFilesEvent event,
    Emitter<UploadState> emit,
  ) async {
    await _uploadMultipleFilesRunner.run(
      onlineTask: (_) async {
        return await UploadOnlineRepository.uploadMultipleFiles(
          files: event.files,
          onProgress: (index, sent, total) {
            // Handle progress for each file
          },
        );
      },
      checkConnectivity: true,
      onSuccess: (urls) {
        if (!emit.isDone) {
          emit(UploadMultipleCompleted(uploadedUrls: urls));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(UploadError(message: error.toString()));
        }
      },
    );
  }

  Future<void> _onCancelUpload(
    CancelUploadEvent event,
    Emitter<UploadState> emit,
  ) async {
    // Cancel any running upload operations
    _uploadImageRunner.cancel();
    _uploadFileRunner.cancel();
    _uploadMultipleImagesRunner.cancel();
    _uploadMultipleFilesRunner.cancel();

    await UploadLocalRepository.removePendingUpload(event.uploadId);
    if (!emit.isDone) {
      emit(UploadCancelled(uploadId: event.uploadId));
    }
  }

  Future<void> _onRetryUpload(
    RetryUploadEvent event,
    Emitter<UploadState> emit,
  ) async {
    // Get failed upload and retry
    final failed = await UploadLocalRepository.getFailedUploads();
    final upload = failed.firstWhere(
      (u) => u.uploadId == event.uploadId,
      orElse: () => throw Exception('Upload not found'),
    );

    // Retry upload
    if (upload.file.isImage) {
      add(UploadImageEvent(file: upload.file));
    } else {
      add(UploadFileEvent(file: upload.file));
    }
  }

  Future<void> _onClearUploads(
    ClearUploadsEvent event,
    Emitter<UploadState> emit,
  ) async {
    await UploadLocalRepository.clearPendingUploads();
    await UploadLocalRepository.clearFailedUploads();
    emit(const UploadInitial());
  }

  Future<void> _onRemoveUploadedFile(
    RemoveUploadedFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    await UploadLocalRepository.removePendingUpload(event.uploadId);
    emit(const UploadInitial());
  }
}

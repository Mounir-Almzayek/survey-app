import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/upload_progress.dart';
import '../../repository/upload_online_repository.dart';
import '../../repository/upload_local_repository.dart';
import '../../service/file_picker_service.dart';
import 'upload_event.dart';
import 'upload_state.dart';

/// Bloc for managing file uploads with support for multiple concurrent survey questions.
class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(const UploadInitial()) {
    on<PickAndUploadImageEvent>(_onPickAndUploadImage);
    on<PickAndUploadFileEvent>(_onPickAndUploadFile);
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

  Future<void> _onPickAndUploadImage(
    PickAndUploadImageEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadPicking(uploads: state.uploads, questionId: event.questionId));

    final file = await FilePickerService.pickImage(source: event.source);
    if (file != null) {
      add(UploadImageEvent(questionId: event.questionId, file: file));
    } else {
      emit(UploadInitial(uploads: state.uploads));
    }
  }

  Future<void> _onPickAndUploadFile(
    PickAndUploadFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadPicking(uploads: state.uploads, questionId: event.questionId));

    final file = await FilePickerService.pickFile(
      allowedExtensions: event.allowedExtensions,
    );
    if (file != null) {
      add(UploadFileEvent(questionId: event.questionId, file: file));
    } else {
      emit(UploadInitial(uploads: state.uploads));
    }
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadPicking(uploads: state.uploads, questionId: event.questionId));

    try {
      final file = await FilePickerService.pickImage(
        source: event.source,
        maxWidth: event.maxWidth,
        maxHeight: event.maxHeight,
        imageQuality: event.imageQuality,
      );

      if (file != null) {
        emit(
          UploadFilePicked(
            uploads: state.uploads,
            questionId: event.questionId,
            file: file,
          ),
        );
      } else {
        emit(UploadInitial(uploads: state.uploads));
      }
    } catch (e) {
      emit(UploadError(uploads: state.uploads, message: e.toString()));
    }
  }

  Future<void> _onPickMultipleImages(
    PickMultipleImagesEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadPicking(uploads: state.uploads, questionId: event.questionId));

    try {
      final files = await FilePickerService.pickMultipleImages(
        maxWidth: event.maxWidth,
        maxHeight: event.maxHeight,
        imageQuality: event.imageQuality,
      );

      if (files.isNotEmpty) {
        emit(
          UploadFilePicked(
            uploads: state.uploads,
            questionId: event.questionId,
            file: files.first,
            multipleFiles: files,
          ),
        );
      } else {
        emit(UploadInitial(uploads: state.uploads));
      }
    } catch (e) {
      emit(UploadError(uploads: state.uploads, message: e.toString()));
    }
  }

  Future<void> _onPickFile(
    PickFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadPicking(uploads: state.uploads, questionId: event.questionId));

    try {
      final file = await FilePickerService.pickFile(
        allowedExtensions: event.allowedExtensions,
        type: event.type,
      );

      if (file != null) {
        emit(
          UploadFilePicked(
            uploads: state.uploads,
            questionId: event.questionId,
            file: file,
          ),
        );
      } else {
        emit(UploadInitial(uploads: state.uploads));
      }
    } catch (e) {
      emit(UploadError(uploads: state.uploads, message: e.toString()));
    }
  }

  Future<void> _onPickMultipleFiles(
    PickMultipleFilesEvent event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadPicking(uploads: state.uploads, questionId: event.questionId));

    try {
      final files = await FilePickerService.pickMultipleFiles(
        allowedExtensions: event.allowedExtensions,
        type: event.type,
      );

      if (files.isNotEmpty) {
        emit(
          UploadFilePicked(
            uploads: state.uploads,
            questionId: event.questionId,
            file: files.first,
            multipleFiles: files,
          ),
        );
      } else {
        emit(UploadInitial(uploads: state.uploads));
      }
    } catch (e) {
      emit(UploadError(uploads: state.uploads, message: e.toString()));
    }
  }

  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<UploadState> emit,
  ) async {
    final progress = UploadProgress(
      uploadId: event.questionId.toString(),
      file: event.file,
      status: UploadStatus.uploading,
      progress: 0.0,
    );

    final updatedUploads = Map<int, UploadProgress>.from(state.uploads);
    updatedUploads[event.questionId] = progress;

    emit(
      UploadUploading(
        uploads: updatedUploads,
        questionId: event.questionId,
        progress: progress,
      ),
    );

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      await UploadLocalRepository.savePendingUpload(progress);

      final url = await UploadOnlineRepository.uploadImage(
        file: event.file,
        onProgress: (sent, total) {
          // Progress placeholder
        },
      );

      final completedProgress = progress.copyWith(
        status: UploadStatus.completed,
        uploadedUrl: url,
        progress: 1.0,
        completedAt: DateTime.now(),
      );

      final currentUploads = Map<int, UploadProgress>.from(state.uploads);
      currentUploads[event.questionId] = completedProgress;

      await UploadLocalRepository.removePendingUpload(
        event.questionId.toString(),
      );

      emit(
        UploadCompleted(
          uploads: currentUploads,
          questionId: event.questionId,
          progress: completedProgress,
          uploadedUrl: url,
        ),
      );
    } catch (e) {
      final failedProgress = progress.copyWith(
        status: UploadStatus.failed,
        error: e.toString(),
      );

      final currentUploads = Map<int, UploadProgress>.from(state.uploads);
      currentUploads[event.questionId] = failedProgress;

      await UploadLocalRepository.saveFailedUpload(failedProgress);
      await UploadLocalRepository.removePendingUpload(
        event.questionId.toString(),
      );

      emit(
        UploadFailed(
          uploads: currentUploads,
          questionId: event.questionId,
          progress: failedProgress,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    final progress = UploadProgress(
      uploadId: event.questionId.toString(),
      file: event.file,
      status: UploadStatus.uploading,
      progress: 0.0,
    );

    final updatedUploads = Map<int, UploadProgress>.from(state.uploads);
    updatedUploads[event.questionId] = progress;

    emit(
      UploadUploading(
        uploads: updatedUploads,
        questionId: event.questionId,
        progress: progress,
      ),
    );

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      await UploadLocalRepository.savePendingUpload(progress);

      final url = await UploadOnlineRepository.uploadFile(
        file: event.file,
        onProgress: (sent, total) {
          // Progress placeholder
        },
      );

      final completedProgress = progress.copyWith(
        status: UploadStatus.completed,
        uploadedUrl: url,
        progress: 1.0,
        completedAt: DateTime.now(),
      );

      final currentUploads = Map<int, UploadProgress>.from(state.uploads);
      currentUploads[event.questionId] = completedProgress;

      await UploadLocalRepository.removePendingUpload(
        event.questionId.toString(),
      );

      emit(
        UploadCompleted(
          uploads: currentUploads,
          questionId: event.questionId,
          progress: completedProgress,
          uploadedUrl: url,
        ),
      );
    } catch (e) {
      final failedProgress = progress.copyWith(
        status: UploadStatus.failed,
        error: e.toString(),
      );

      final currentUploads = Map<int, UploadProgress>.from(state.uploads);
      currentUploads[event.questionId] = failedProgress;

      await UploadLocalRepository.saveFailedUpload(failedProgress);
      await UploadLocalRepository.removePendingUpload(
        event.questionId.toString(),
      );

      emit(
        UploadFailed(
          uploads: currentUploads,
          questionId: event.questionId,
          progress: failedProgress,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUploadMultipleImages(
    UploadMultipleImagesEvent event,
    Emitter<UploadState> emit,
  ) async {
    try {
      final urls = await UploadOnlineRepository.uploadMultipleImages(
        files: event.files,
      );
      emit(UploadMultipleCompleted(uploads: state.uploads, uploadedUrls: urls));
    } catch (e) {
      emit(UploadError(uploads: state.uploads, message: e.toString()));
    }
  }

  Future<void> _onUploadMultipleFiles(
    UploadMultipleFilesEvent event,
    Emitter<UploadState> emit,
  ) async {
    try {
      final urls = await UploadOnlineRepository.uploadMultipleFiles(
        files: event.files,
      );
      emit(UploadMultipleCompleted(uploads: state.uploads, uploadedUrls: urls));
    } catch (e) {
      emit(UploadError(uploads: state.uploads, message: e.toString()));
    }
  }

  Future<void> _onCancelUpload(
    CancelUploadEvent event,
    Emitter<UploadState> emit,
  ) async {
    final currentUploads = Map<int, UploadProgress>.from(state.uploads);
    currentUploads.remove(event.questionId);

    await UploadLocalRepository.removePendingUpload(
      event.questionId.toString(),
    );
    emit(
      UploadCancelled(uploads: currentUploads, questionId: event.questionId),
    );
  }

  Future<void> _onRetryUpload(
    RetryUploadEvent event,
    Emitter<UploadState> emit,
  ) async {
    final upload = state.uploads[event.questionId];
    if (upload != null) {
      if (upload.file.isImage) {
        add(UploadImageEvent(questionId: event.questionId, file: upload.file));
      } else {
        add(UploadFileEvent(questionId: event.questionId, file: upload.file));
      }
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
    final currentUploads = Map<int, UploadProgress>.from(state.uploads);
    currentUploads.remove(event.questionId);
    await UploadLocalRepository.removePendingUpload(
      event.questionId.toString(),
    );
    emit(UploadInitial(uploads: currentUploads));
  }
}

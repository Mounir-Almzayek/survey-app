import 'package:equatable/equatable.dart';
import '../../models/upload_file.dart';
import '../../models/upload_progress.dart';

/// States for Upload Bloc
abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UploadInitial extends UploadState {
  const UploadInitial();
}

/// Loading state (picking file)
class UploadPicking extends UploadState {
  const UploadPicking();
}

/// File picked successfully
class UploadFilePicked extends UploadState {
  final UploadFile file;
  final List<UploadFile>? multipleFiles;

  const UploadFilePicked({
    required this.file,
    this.multipleFiles,
  });

  @override
  List<Object?> get props => [file, multipleFiles];
}

/// Uploading state
class UploadUploading extends UploadState {
  final UploadProgress progress;

  const UploadUploading({required this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Upload completed
class UploadCompleted extends UploadState {
  final UploadProgress progress;
  final String uploadedUrl;

  const UploadCompleted({
    required this.progress,
    required this.uploadedUrl,
  });

  @override
  List<Object?> get props => [progress, uploadedUrl];
}

/// Multiple uploads completed
class UploadMultipleCompleted extends UploadState {
  final List<String> uploadedUrls;

  const UploadMultipleCompleted({required this.uploadedUrls});

  @override
  List<Object?> get props => [uploadedUrls];
}

/// Upload failed
class UploadFailed extends UploadState {
  final UploadProgress progress;
  final String error;

  const UploadFailed({
    required this.progress,
    required this.error,
  });

  @override
  List<Object?> get props => [progress, error];
}

/// Upload cancelled
class UploadCancelled extends UploadState {
  final String uploadId;

  const UploadCancelled({required this.uploadId});

  @override
  List<Object?> get props => [uploadId];
}

/// Error state
class UploadError extends UploadState {
  final String message;

  const UploadError({required this.message});

  @override
  List<Object?> get props => [message];
}


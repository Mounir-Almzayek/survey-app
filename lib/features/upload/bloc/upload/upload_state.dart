import 'package:equatable/equatable.dart';
import '../../models/upload_file.dart';
import '../../models/upload_progress.dart';

/// States for Upload Bloc
abstract class UploadState extends Equatable {
  final Map<int, UploadProgress> uploads;

  const UploadState({this.uploads = const {}});

  @override
  List<Object?> get props => [uploads];
}

/// Initial state
class UploadInitial extends UploadState {
  const UploadInitial({super.uploads});
}

/// Loading state (picking file)
class UploadPicking extends UploadState {
  final int? questionId;
  const UploadPicking({super.uploads, this.questionId});

  @override
  List<Object?> get props => [uploads, questionId];
}

/// File picked successfully
class UploadFilePicked extends UploadState {
  final int questionId;
  final UploadFile file;
  final List<UploadFile>? multipleFiles;

  const UploadFilePicked({
    super.uploads,
    required this.questionId,
    required this.file,
    this.multipleFiles,
  });

  @override
  List<Object?> get props => [uploads, questionId, file, multipleFiles];
}

/// Uploading state
class UploadUploading extends UploadState {
  final int questionId;
  final UploadProgress progress;

  const UploadUploading({
    super.uploads,
    required this.questionId,
    required this.progress,
  });

  @override
  List<Object?> get props => [uploads, questionId, progress];
}

/// Upload completed
class UploadCompleted extends UploadState {
  final int questionId;
  final UploadProgress progress;
  final String uploadedUrl;

  const UploadCompleted({
    super.uploads,
    required this.questionId,
    required this.progress,
    required this.uploadedUrl,
  });

  @override
  List<Object?> get props => [uploads, questionId, progress, uploadedUrl];
}

/// Multiple uploads completed
class UploadMultipleCompleted extends UploadState {
  final List<String> uploadedUrls;

  const UploadMultipleCompleted({
    super.uploads,
    required this.uploadedUrls,
  });

  @override
  List<Object?> get props => [uploads, uploadedUrls];
}

/// Upload failed
class UploadFailed extends UploadState {
  final int questionId;
  final UploadProgress progress;
  final String error;

  const UploadFailed({
    super.uploads,
    required this.questionId,
    required this.progress,
    required this.error,
  });

  @override
  List<Object?> get props => [uploads, questionId, progress, error];
}

/// Upload cancelled
class UploadCancelled extends UploadState {
  final int questionId;

  const UploadCancelled({
    super.uploads,
    required this.questionId,
  });

  @override
  List<Object?> get props => [uploads, questionId];
}

/// Error state
class UploadError extends UploadState {
  final String message;

  const UploadError({
    super.uploads,
    required this.message,
  });

  @override
  List<Object?> get props => [uploads, message];
}



import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/upload_file.dart';

/// Events for Upload Bloc
abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

/// Pick an image and immediately upload it (Common for surveys)
class PickAndUploadImageEvent extends UploadEvent {
  final int questionId;
  final ImageSource source;

  const PickAndUploadImageEvent({
    required this.questionId,
    this.source = ImageSource.gallery,
  });

  @override
  List<Object?> get props => [questionId, source];
}

/// Pick a file and immediately upload it
class PickAndUploadFileEvent extends UploadEvent {
  final int questionId;
  final List<String>? allowedExtensions;

  const PickAndUploadFileEvent({
    required this.questionId,
    this.allowedExtensions,
  });

  @override
  List<Object?> get props => [questionId, allowedExtensions];
}

/// Pick an image from gallery or camera
class PickImageEvent extends UploadEvent {
  final int questionId;
  final ImageSource source;
  final int? maxWidth;
  final int? maxHeight;
  final int imageQuality;

  const PickImageEvent({
    required this.questionId,
    this.source = ImageSource.gallery,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality = 85,
  });

  @override
  List<Object?> get props => [questionId, source, maxWidth, maxHeight, imageQuality];
}

/// Pick multiple images
class PickMultipleImagesEvent extends UploadEvent {
  final int questionId;
  final int? maxWidth;
  final int? maxHeight;
  final int imageQuality;

  const PickMultipleImagesEvent({
    required this.questionId,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality = 85,
  });

  @override
  List<Object?> get props => [questionId, maxWidth, maxHeight, imageQuality];
}

/// Pick a file
class PickFileEvent extends UploadEvent {
  final int questionId;
  final List<String>? allowedExtensions;
  final String? type;

  const PickFileEvent({
    required this.questionId,
    this.allowedExtensions,
    this.type,
  });

  @override
  List<Object?> get props => [questionId, allowedExtensions, type];
}

/// Pick multiple files
class PickMultipleFilesEvent extends UploadEvent {
  final int questionId;
  final List<String>? allowedExtensions;
  final String? type;

  const PickMultipleFilesEvent({
    required this.questionId,
    this.allowedExtensions,
    this.type,
  });

  @override
  List<Object?> get props => [questionId, allowedExtensions, type];
}

/// Upload a single image
class UploadImageEvent extends UploadEvent {
  final int questionId;
  final UploadFile file;

  const UploadImageEvent({
    required this.questionId,
    required this.file,
  });

  @override
  List<Object?> get props => [questionId, file];
}

/// Upload a single file
class UploadFileEvent extends UploadEvent {
  final int questionId;
  final UploadFile file;

  const UploadFileEvent({
    required this.questionId,
    required this.file,
  });

  @override
  List<Object?> get props => [questionId, file];
}

/// Upload multiple images
class UploadMultipleImagesEvent extends UploadEvent {
  final int questionId;
  final List<UploadFile> files;

  const UploadMultipleImagesEvent({
    required this.questionId,
    required this.files,
  });

  @override
  List<Object?> get props => [questionId, files];
}

/// Upload multiple files
class UploadMultipleFilesEvent extends UploadEvent {
  final int questionId;
  final List<UploadFile> files;

  const UploadMultipleFilesEvent({
    required this.questionId,
    required this.files,
  });

  @override
  List<Object?> get props => [questionId, files];
}

/// Cancel upload
class CancelUploadEvent extends UploadEvent {
  final int questionId;

  const CancelUploadEvent({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

/// Retry failed upload
class RetryUploadEvent extends UploadEvent {
  final int questionId;

  const RetryUploadEvent({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

/// Clear all uploads
class ClearUploadsEvent extends UploadEvent {
  const ClearUploadsEvent();
}

/// Remove uploaded file
class RemoveUploadedFileEvent extends UploadEvent {
  final int questionId;

  const RemoveUploadedFileEvent({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

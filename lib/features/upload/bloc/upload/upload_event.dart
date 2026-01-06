import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/upload_file.dart';

/// Events for Upload Bloc
abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

/// Pick an image from gallery or camera
class PickImageEvent extends UploadEvent {
  final ImageSource source;
  final int? maxWidth;
  final int? maxHeight;
  final int imageQuality;

  const PickImageEvent({
    this.source = ImageSource.gallery,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality = 85,
  });

  @override
  List<Object?> get props => [source, maxWidth, maxHeight, imageQuality];
}

/// Pick multiple images
class PickMultipleImagesEvent extends UploadEvent {
  final int? maxWidth;
  final int? maxHeight;
  final int imageQuality;

  const PickMultipleImagesEvent({
    this.maxWidth,
    this.maxHeight,
    this.imageQuality = 85,
  });

  @override
  List<Object?> get props => [maxWidth, maxHeight, imageQuality];
}

/// Pick a file
class PickFileEvent extends UploadEvent {
  final List<String>? allowedExtensions;
  final String? type;

  const PickFileEvent({
    this.allowedExtensions,
    this.type,
  });

  @override
  List<Object?> get props => [allowedExtensions, type];
}

/// Pick multiple files
class PickMultipleFilesEvent extends UploadEvent {
  final List<String>? allowedExtensions;
  final String? type;

  const PickMultipleFilesEvent({
    this.allowedExtensions,
    this.type,
  });

  @override
  List<Object?> get props => [allowedExtensions, type];
}

/// Upload a single image
class UploadImageEvent extends UploadEvent {
  final UploadFile file;

  const UploadImageEvent({required this.file});

  @override
  List<Object?> get props => [file];
}

/// Upload a single file
class UploadFileEvent extends UploadEvent {
  final UploadFile file;

  const UploadFileEvent({required this.file});

  @override
  List<Object?> get props => [file];
}

/// Upload multiple images
class UploadMultipleImagesEvent extends UploadEvent {
  final List<UploadFile> files;

  const UploadMultipleImagesEvent({required this.files});

  @override
  List<Object?> get props => [files];
}

/// Upload multiple files
class UploadMultipleFilesEvent extends UploadEvent {
  final List<UploadFile> files;

  const UploadMultipleFilesEvent({required this.files});

  @override
  List<Object?> get props => [files];
}

/// Cancel upload
class CancelUploadEvent extends UploadEvent {
  final String uploadId;

  const CancelUploadEvent({required this.uploadId});

  @override
  List<Object?> get props => [uploadId];
}

/// Retry failed upload
class RetryUploadEvent extends UploadEvent {
  final String uploadId;

  const RetryUploadEvent({required this.uploadId});

  @override
  List<Object?> get props => [uploadId];
}

/// Clear all uploads
class ClearUploadsEvent extends UploadEvent {
  const ClearUploadsEvent();
}

/// Remove uploaded file
class RemoveUploadedFileEvent extends UploadEvent {
  final String uploadId;

  const RemoveUploadedFileEvent({required this.uploadId});

  @override
  List<Object?> get props => [uploadId];
}


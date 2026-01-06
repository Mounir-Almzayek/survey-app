import 'package:equatable/equatable.dart';
import 'upload_file.dart';

/// Model representing upload progress
class UploadProgress extends Equatable {
  final String uploadId;
  final UploadFile file;
  final double progress; // 0.0 to 1.0
  final UploadStatus status;
  final String? uploadedUrl;
  final String? error;
  final DateTime? completedAt;

  const UploadProgress({
    required this.uploadId,
    required this.file,
    this.progress = 0.0,
    this.status = UploadStatus.pending,
    this.uploadedUrl,
    this.error,
    this.completedAt,
  });

  UploadProgress copyWith({
    String? uploadId,
    UploadFile? file,
    double? progress,
    UploadStatus? status,
    String? uploadedUrl,
    String? error,
    DateTime? completedAt,
  }) {
    return UploadProgress(
      uploadId: uploadId ?? this.uploadId,
      file: file ?? this.file,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      error: error ?? this.error,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if upload is in progress
  bool get isUploading => status == UploadStatus.uploading;

  /// Check if upload is completed
  bool get isCompleted => status == UploadStatus.completed;

  /// Check if upload failed
  bool get isFailed => status == UploadStatus.failed;

  /// Get progress percentage (0-100)
  int get progressPercentage => (progress * 100).round();

  @override
  List<Object?> get props => [
    uploadId,
    file,
    progress,
    status,
    uploadedUrl,
    error,
    completedAt,
  ];
}

/// Upload status enum
enum UploadStatus { pending, uploading, completed, failed, cancelled }

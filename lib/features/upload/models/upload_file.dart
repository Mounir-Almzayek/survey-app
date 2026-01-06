import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

/// Model representing a file to be uploaded
class UploadFile extends Equatable {
  final String id;
  final XFile file;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final DateTime createdAt;

  const UploadFile({
    required this.id,
    required this.file,
    this.fileName,
    this.mimeType,
    this.fileSize,
    required this.createdAt,
  });

  /// Create UploadFile from XFile
  factory UploadFile.fromXFile(XFile file) {
    return UploadFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      file: file,
      fileName: file.name,
      mimeType: file.mimeType,
      createdAt: DateTime.now(),
    );
  }

  /// Get file extension
  String? get extension {
    final name = fileName ?? file.name;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return null;
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// Check if file is an image
  bool get isImage {
    final ext = extension;
    if (ext == null) return false;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  /// Check if file is a document
  bool get isDocument {
    final ext = extension;
    if (ext == null) return false;
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'].contains(ext);
  }

  @override
  List<Object?> get props => [
    id,
    file.path,
    fileName,
    mimeType,
    fileSize,
    createdAt,
  ];
}

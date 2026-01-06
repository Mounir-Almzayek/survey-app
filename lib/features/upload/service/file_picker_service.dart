import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/upload_file.dart';

/// Service for picking files and images
class FilePickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick a single image from gallery or camera
  static Future<UploadFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        return UploadFile.fromXFile(image);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple images
  static Future<List<UploadFile>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      return images.map((image) => UploadFile.fromXFile(image)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Pick a file (document, PDF, etc.)
  static Future<UploadFile?> pickFile({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final xFile = XFile(file.path);
        return UploadFile.fromXFile(xFile);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple files
  static Future<List<UploadFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.where((file) => file.path != null).map((file) {
          final xFile = XFile(file.path!);
          return UploadFile.fromXFile(xFile);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

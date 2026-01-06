import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/upload_progress.dart';

/// Repository for managing uploads locally (offline queue)
class UploadLocalRepository {
  static const String _pendingUploadsKey = 'pending_uploads';
  static const String _failedUploadsKey = 'failed_uploads';

  /// Save pending upload to local storage
  static Future<void> savePendingUpload(UploadProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingUploads();
    pending.add(progress);

    final jsonList = pending.map((p) => _progressToJson(p)).toList();
    await prefs.setString(_pendingUploadsKey, jsonEncode(jsonList));
  }

  /// Get all pending uploads
  static Future<List<UploadProgress>> getPendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingUploadsKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _progressFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove pending upload
  static Future<void> removePendingUpload(String uploadId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingUploads();
    pending.removeWhere((p) => p.uploadId == uploadId);

    final jsonList = pending.map((p) => _progressToJson(p)).toList();
    await prefs.setString(_pendingUploadsKey, jsonEncode(jsonList));
  }

  /// Save failed upload
  static Future<void> saveFailedUpload(UploadProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final failed = await getFailedUploads();
    failed.add(progress);

    final jsonList = failed.map((p) => _progressToJson(p)).toList();
    await prefs.setString(_failedUploadsKey, jsonEncode(jsonList));
  }

  /// Get all failed uploads
  static Future<List<UploadProgress>> getFailedUploads() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_failedUploadsKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _progressFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear all pending uploads
  static Future<void> clearPendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUploadsKey);
  }

  /// Clear all failed uploads
  static Future<void> clearFailedUploads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedUploadsKey);
  }

  // Helper methods for JSON serialization
  static Map<String, dynamic> _progressToJson(UploadProgress progress) {
    return {
      'uploadId': progress.uploadId,
      'filePath': progress.file.file.path,
      'fileName': progress.file.fileName,
      'progress': progress.progress,
      'status': progress.status.name,
      'uploadedUrl': progress.uploadedUrl,
      'error': progress.error,
      'completedAt': progress.completedAt?.toIso8601String(),
    };
  }

  static UploadProgress _progressFromJson(Map<String, dynamic> json) {
    // Note: This is a simplified version. In production, you'd need to
    // reconstruct the XFile from the path, which may not exist if file was deleted
    // For now, we'll create a minimal representation
    throw UnimplementedError(
      'Reconstructing UploadProgress from JSON requires file system access. '
      'This should be handled differently in production.',
    );
  }
}

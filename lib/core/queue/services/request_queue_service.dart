import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../services/hive_service.dart';
import '../models/request_queue_item.dart';

/// Request Queue Service
/// Manages queued API requests using Hive database
class RequestQueueService {
  static const String _queueKey = 'queued_requests';

  /// Initialize queue service
  static Future<void> init() async {
    await HiveService.init();
  }

  /// Get the queue box
  static Future<dynamic> _getBox() async {
    return await HiveService.getRequestQueueBox();
  }

  /// Add a request to the queue
  static Future<void> enqueue(RequestQueueItem item) async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      queue.add(item.toJson());
      await box.put(_queueKey, json.encode(queue));

      if (kDebugMode) {
        debugPrint(
          '[RequestQueueService] enqueue -> id=${item.id}, '
          'path=${item.request.path}, totalInQueue=${queue.length}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RequestQueueService] enqueue ERROR: $e');
      }
    }
  }

  /// Get all pending requests from the queue
  static Future<List<RequestQueueItem>> getPendingRequests() async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      return queue
          .map(
              (item) => RequestQueueItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.status == QueueItemStatus.pending)
          .toList()
        ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    } catch (e) {
      return [];
    }
  }

  /// Get all requests from the queue
  static Future<List<RequestQueueItem>> getAllRequests() async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      return queue
          .map(
              (item) => RequestQueueItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Update a request in the queue
  static Future<void> updateRequest(RequestQueueItem item) async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      final index = queue.indexWhere(
        (q) => (q as Map<String, dynamic>)['id'] == item.id,
      );
      if (index != -1) {
        queue[index] = item.toJson();
        await box.put(_queueKey, json.encode(queue));
      }
    } catch (e) {}
  }

  /// Remove a request from the queue
  static Future<void> removeRequest(String id) async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      queue.removeWhere(
        (q) => (q as Map<String, dynamic>)['id'] == id,
      );
      await box.put(_queueKey, json.encode(queue));
    } catch (e) {}
  }

  /// Clear all requests from the queue
  static Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.delete(_queueKey);
    } catch (e) {}
  }

  /// Get the queue from box
  static List<dynamic> _getQueue(dynamic box) {
    final queueData = box.get(_queueKey) as String?;
    if (queueData == null || queueData.isEmpty) {
      return [];
    }
    try {
      return json.decode(queueData) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }
}


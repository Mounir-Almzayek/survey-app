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

  /// Get all pending requests from the queue.
  /// Sorted so start_response runs before section_save (ensures real response ids before section sync).
  static Future<List<RequestQueueItem>> getPendingRequests() async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      final pending = queue
          .map(
            (item) => RequestQueueItem.fromJson(item as Map<String, dynamic>),
          )
          .where((item) => item.status == QueueItemStatus.pending)
          .toList();
      pending.sort((a, b) {
        final aStart = a.metadata?['type'] == 'start_response';
        final bStart = b.metadata?['type'] == 'start_response';
        if (aStart && !bStart) return -1;
        if (!aStart && bStart) return 1;
        return a.queuedAt.compareTo(b.queuedAt);
      });
      return pending;
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
            (item) => RequestQueueItem.fromJson(item as Map<String, dynamic>),
          )
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
      queue.removeWhere((q) => (q as Map<String, dynamic>)['id'] == id);
      await box.put(_queueKey, json.encode(queue));
    } catch (e) {}
  }

  /// Reset processing (stuck) and failed requests to pending for retry.
  /// Use on app init and when connectivity restores to recover stuck/failed items.
  static Future<void> resetStuckAndFailedRequests() async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      bool changed = false;

      for (int i = 0; i < queue.length; i++) {
        final itemMap = Map<String, dynamic>.from(queue[i] as Map);
        final status = itemMap['status'] as String?;
        if (status == QueueItemStatus.processing.name ||
            status == QueueItemStatus.failed.name) {
          itemMap['status'] = QueueItemStatus.pending.name;
          itemMap['retryCount'] = 0;
          queue[i] = itemMap;
          changed = true;
        }
      }

      if (changed) {
        await box.put(_queueKey, json.encode(queue));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[RequestQueueService] resetStuckAndFailedRequests ERROR: $e',
        );
      }
    }
  }

  /// Reset all failed requests to pending
  static Future<void> resetFailedRequests() async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      bool changed = false;

      for (int i = 0; i < queue.length; i++) {
        final itemMap = Map<String, dynamic>.from(queue[i] as Map);
        if (itemMap['status'] == QueueItemStatus.failed.name) {
          itemMap['status'] = QueueItemStatus.pending.name;
          itemMap['retryCount'] = 0;
          queue[i] = itemMap;
          changed = true;
        }
      }

      if (changed) {
        await box.put(_queueKey, json.encode(queue));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RequestQueueService] resetFailedRequests ERROR: $e');
      }
    }
  }

  /// Remap IDs in all queued requests (useful when a dummy ID is replaced by a real one from server)
  static Future<void> remapIds(int oldId, int newId) async {
    try {
      final box = await _getBox();
      final queue = _getQueue(box);
      bool changed = false;

      final oldIdStr = oldId.toString();
      final newIdStr = newId.toString();

      final oldPathSegment = '/$oldIdStr';
      final newPathSegment = '/$newIdStr';

      for (int i = 0; i < queue.length; i++) {
        var itemMap = Map<String, dynamic>.from(queue[i] as Map);
        bool itemChanged = false;

        // 1. Check path
        final requestMap = Map<String, dynamic>.from(itemMap['request'] as Map);
        String path = requestMap['path'] as String;

        if (path.contains(oldPathSegment)) {
          // Robust path replacement handling segments like /response/-1/section or /response/-1
          requestMap['path'] = path.replaceAllMapped(
            RegExp('$oldPathSegment(/|\$)'),
            (match) => '$newPathSegment${match.group(1)}',
          );
          itemChanged = true;
        }

        // 2. Check body (Recursive search and replace)
        if (requestMap['body'] != null) {
          final newBody = _recursiveReplace(requestMap['body'], oldId, newId);
          if (newBody != requestMap['body']) {
            requestMap['body'] = newBody;
            itemChanged = true;
          }
        }

        // 3. Check metadata
        if (itemMap['metadata'] != null) {
          final newMetadata = _recursiveReplace(
            itemMap['metadata'],
            oldId,
            newId,
          );
          if (newMetadata != itemMap['metadata']) {
            itemMap['metadata'] = newMetadata;
            itemChanged = true;
          }
        }

        if (itemChanged) {
          itemMap['request'] = requestMap;
          queue[i] = itemMap;
          changed = true;
        }
      }

      if (changed) {
        await box.put(_queueKey, json.encode(queue));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RequestQueueService] remapIds ERROR: $e');
      }
    }
  }

  static dynamic _recursiveReplace(dynamic data, int oldId, int newId) {
    if (data is int) {
      return data == oldId ? newId : data;
    } else if (data is String) {
      final oldIdStr = oldId.toString();
      final newIdStr = newId.toString();
      if (data == oldIdStr) return newIdStr;
      return data.replaceAll(oldIdStr, newIdStr);
    } else if (data is Map) {
      final Map<String, dynamic> result = {};
      data.forEach((key, value) {
        result[key.toString()] = _recursiveReplace(value, oldId, newId);
      });
      return result;
    } else if (data is List) {
      return data.map((e) => _recursiveReplace(e, oldId, newId)).toList();
    }
    return data;
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

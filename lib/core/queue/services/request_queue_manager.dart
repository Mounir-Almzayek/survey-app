import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../data/network/api_request.dart';
import '../../../features/assignment/repository/assignment_repository.dart';
import '../models/request_queue_item.dart';
import 'request_queue_service.dart';

/// Request Queue Manager
/// Manages sending queued requests when online
class RequestQueueManager {
  static final RequestQueueManager _instance = RequestQueueManager._internal();
  factory RequestQueueManager() => _instance;
  RequestQueueManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isProcessing = false;
  bool _isOnline = true;

  final _queueStatusController = StreamController<QueueStatus>.broadcast();
  Stream<QueueStatus> get queueStatusStream => _queueStatusController.stream;

  final _responseController = StreamController<QueueResponse>.broadcast();
  Stream<QueueResponse> get responseStream => _responseController.stream;

  // In-memory success callbacks
  final Map<String, FutureOr<void> Function(dynamic response)>
  _successCallbacks = {};

  Future<void> init() async {
    await RequestQueueService.init();

    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    await RequestQueueService.resetStuckAndFailedRequests();
    final initialPending = await RequestQueueService.getPendingRequests();
    _queueStatusController.add(
      QueueStatus(isOnline: _isOnline, queueLength: initialPending.length),
    );

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      _isOnline = !result.contains(ConnectivityResult.none);

      if (_isOnline) {
        if (!_isProcessing) {
          await RequestQueueService.resetStuckAndFailedRequests();
        }
        _processQueue();
      }

      final pending = await RequestQueueService.getPendingRequests();
      _queueStatusController.add(
        QueueStatus(isOnline: _isOnline, queueLength: pending.length),
      );
    });

    if (_isOnline) {
      _processQueue();
    }
  }

  Future<bool> queueRequest(
    APIRequest request, {
    Map<String, dynamic>? metadata,
    FutureOr<void> Function(dynamic response)? onSuccess,
  }) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();

    if (onSuccess != null) {
      _successCallbacks[requestId] = onSuccess;
    }

    if (request.method == HTTPMethod.get) {
      try {
        final response = await request.send();
        await onSuccess?.call(response);
        _responseController.add(
          QueueResponse(
            requestId: requestId,
            success: true,
            response: response,
          ),
        );
        _successCallbacks.remove(requestId);
        return false;
      } catch (e) {
        _responseController.add(
          QueueResponse(
            requestId: requestId,
            success: false,
            error: e.toString(),
          ),
        );
        _successCallbacks.remove(requestId);
        return false;
      }
    }

    if (_isOnline && !_isProcessing) {
      // SAFETY CHECK: Don't attempt to send requests containing dummy IDs (negative numbers)
      final hasDummyId =
          request.path.contains('/-') ||
          (request.body is Map &&
              request.body.toString().contains(': -')); // Simple heuristic

      if (!hasDummyId) {
        try {
          final response = await request.send();
          await onSuccess?.call(response);
          _responseController.add(
            QueueResponse(
              requestId: requestId,
              success: true,
              response: response,
            ),
          );
          _successCallbacks.remove(requestId);
          return false;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[RequestQueueManager] queueRequest send failed: $e');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '[RequestQueueManager] Dummy ID detected in request. Force queuing.',
          );
        }
      }
    }

    final item = RequestQueueItem(
      id: requestId,
      request: request,
      queuedAt: DateTime.now(),
      metadata: metadata,
    );

    await RequestQueueService.enqueue(item);

    final pendingCount = await RequestQueueService.getPendingRequests();

    _queueStatusController.add(
      QueueStatus(isOnline: _isOnline, queueLength: pendingCount.length),
    );

    return true;
  }

  Future<void> retryAll() async {
    await RequestQueueService.resetFailedRequests();
    _processQueue();
  }

  Future<void> clearAll() async {
    await RequestQueueService.clearAll();
    _queueStatusController.add(
      QueueStatus(isOnline: _isOnline, queueLength: 0),
    );
  }

  Future<void> _processQueue() async {
    if (_isProcessing || !_isOnline) return;

    _isProcessing = true;

    while (_isOnline) {
      try {
        final pending = await RequestQueueService.getPendingRequests();
        if (pending.isEmpty) {
          _isProcessing = false;
          _queueStatusController.add(
            QueueStatus(isOnline: _isOnline, queueLength: 0),
          );
          // Reconcile local quota counts with server-truth after the queue
          // drains. Fire-and-forget — failure tolerated, next foreground retries.
          unawaited(AssignmentRepository.refreshAllAssignments());
          return;
        }

        final item = pending.first;

        await RequestQueueService.updateRequest(
          item.copyWith(status: QueueItemStatus.processing),
        );

        try {
          final response = await item.request.send();

          await RequestQueueService.updateRequest(
            item.copyWith(status: QueueItemStatus.completed),
          );

          // Trigger success callback if it exists in memory
          if (_successCallbacks.containsKey(item.id)) {
            await _successCallbacks[item.id]!(response);
            _successCallbacks.remove(item.id);
          }

          _responseController.add(
            QueueResponse(
              requestId: item.id,
              success: true,
              response: response,
            ),
          );

          // SMART REMAPPING: Detect and trigger remapping if required
          if (item.metadata != null &&
              item.metadata!['type'] == 'start_response' &&
              item.metadata!['dummyId'] != null) {
            final dummyId = item.metadata!['dummyId'] as int;
            final realId = response.data['data']['id'] as int;

            // Trigger the repository-specific handler
            await AssignmentRepository.handleStartResponseSync(dummyId, realId);
          }

          await Future.delayed(const Duration(seconds: 1));
          await RequestQueueService.removeRequest(item.id);
        } catch (e) {
          final updatedItem = item.copyWith(
            status: QueueItemStatus.failed,
            retryCount: item.retryCount + 1,
          );
          await RequestQueueService.updateRequest(updatedItem);

          _responseController.add(
            QueueResponse(
              requestId: item.id,
              success: false,
              error: e.toString(),
            ),
          );

          if (updatedItem.retryCount >=
              RequestQueueService.maxQueueSendFailuresBeforeDrop) {
            await Future.delayed(const Duration(seconds: 1));
            await RequestQueueService.removeRequest(item.id);
          }
        }
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('[RequestQueueManager] Unexpected ERROR: $e\n$stack');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isProcessing = false;
  }

  Future<QueueStatus> getStatus() async {
    final pending = await RequestQueueService.getPendingRequests();
    return QueueStatus(isOnline: _isOnline, queueLength: pending.length);
  }

  /// After backgrounding, connectivity may not emit; stuck `processing` items
  /// are otherwise invisible to [getPendingRequests].
  Future<void> onAppResumed() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = !result.contains(ConnectivityResult.none);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RequestQueueManager] onAppResumed connectivity check: $e');
      }
    }

    await RequestQueueService.resetStuckAndFailedRequests();
    final pending = await RequestQueueService.getPendingRequests();
    _queueStatusController.add(
      QueueStatus(isOnline: _isOnline, queueLength: pending.length),
    );

    if (_isOnline) {
      _processQueue();
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _queueStatusController.close();
    _responseController.close();
  }
}

class QueueStatus {
  final bool isOnline;
  final int queueLength;

  QueueStatus({required this.isOnline, required this.queueLength});
}

class QueueResponse {
  final String requestId;
  final bool success;
  final dynamic response;
  final String? error;

  QueueResponse({
    required this.requestId,
    required this.success,
    this.response,
    this.error,
  });
}

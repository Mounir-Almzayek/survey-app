import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../data/network/api_request.dart';
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

  Future<void> init() async {
    await RequestQueueService.init();

    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    final initialPending = await RequestQueueService.getPendingRequests();
    _queueStatusController.add(
      QueueStatus(isOnline: _isOnline, queueLength: initialPending.length),
    );

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      if (!wasOnline && _isOnline) {
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

  Future<bool> queueRequest(APIRequest request) async {
    if (request.method == HTTPMethod.get) {
      try {
        final response = await request.send();
        _responseController.add(
          QueueResponse(requestId: '', success: true, response: response),
        );
        return false;
      } catch (e) {
        _responseController.add(
          QueueResponse(requestId: '', success: false, error: e.toString()),
        );
        return false;
      }
    }

    if (_isOnline && !_isProcessing) {
      try {
        final response = await request.send();
        _responseController.add(
          QueueResponse(requestId: '', success: true, response: response),
        );
        return false;
      } catch (e) {}
    }

    final item = RequestQueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      request: request,
      queuedAt: DateTime.now(),
    );

    await RequestQueueService.enqueue(item);

    final pendingCount = await RequestQueueService.getPendingRequests();

    _queueStatusController.add(
      QueueStatus(isOnline: _isOnline, queueLength: pendingCount.length),
    );

    return true;
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

          _responseController.add(
            QueueResponse(
              requestId: item.id,
              success: true,
              response: response,
            ),
          );

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

          if (updatedItem.retryCount >= 3) {
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

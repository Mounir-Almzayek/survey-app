import '../../../data/network/api_request.dart';

/// Request Queue Item Model
/// Represents a queued API request that needs to be sent when online
class RequestQueueItem {
  /// Unique ID for the queued request
  final String id;

  /// The API request to be sent
  final APIRequest request;

  /// Timestamp when the request was queued
  final DateTime queuedAt;

  /// Number of retry attempts
  final int retryCount;

  /// Status of the queued request
  final QueueItemStatus status;

  /// Optional metadata for the request (e.g., for displaying in snackbar)
  final Map<String, dynamic>? metadata;

  RequestQueueItem({
    required this.id,
    required this.request,
    required this.queuedAt,
    this.retryCount = 0,
    this.status = QueueItemStatus.pending,
    this.metadata,
  });

  /// Create RequestQueueItem from JSON
  factory RequestQueueItem.fromJson(Map<String, dynamic> json) {
    return RequestQueueItem(
      id: json['id'] as String,
      request: APIRequest.fromJson(json['request'] as Map<String, dynamic>),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: QueueItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QueueItemStatus.pending,
      ),
      metadata: json['metadata'] != null
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  /// Convert RequestQueueItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request.toJson(),
      'queuedAt': queuedAt.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  RequestQueueItem copyWith({
    String? id,
    APIRequest? request,
    DateTime? queuedAt,
    int? retryCount,
    QueueItemStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return RequestQueueItem(
      id: id ?? this.id,
      request: request ?? this.request,
      queuedAt: queuedAt ?? this.queuedAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Status of a queued request
enum QueueItemStatus { pending, processing, completed, failed }

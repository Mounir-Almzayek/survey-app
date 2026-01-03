part of 'queue_session_bloc.dart';

class QueueSessionItem extends Equatable {
  final RequestQueueItem item;
  final QueueResponse? lastResponse;

  const QueueSessionItem({
    required this.item,
    this.lastResponse,
  });

  QueueSessionItem copyWith({
    RequestQueueItem? item,
    QueueResponse? lastResponse,
  }) {
    return QueueSessionItem(
      item: item ?? this.item,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }

  @override
  List<Object?> get props => [item, lastResponse];
}

class QueueSessionState extends Equatable {
  final Map<String, QueueSessionItem> items;

  const QueueSessionState({
    required this.items,
  });

  QueueSessionState copyWith({
    Map<String, QueueSessionItem>? items,
  }) {
    return QueueSessionState(
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [items];
}


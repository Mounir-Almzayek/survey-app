import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/request_queue_item.dart';
import '../../services/request_queue_manager.dart';

part 'queue_session_event.dart';
part 'queue_session_state.dart';

class QueueSessionBloc extends Bloc<QueueSessionEvent, QueueSessionState> {
  late final StreamSubscription<QueueResponse> _responseSub;

  QueueSessionBloc({
    required Map<String, RequestQueueItem> initialItems,
  }) : super(QueueSessionState(
          items: {
            for (final entry in initialItems.entries)
              entry.key: QueueSessionItem(
                item: entry.value,
                lastResponse: null,
              ),
          },
        )) {
    on<QueueSessionItemUpdated>(_onItemUpdated);
    on<QueueSessionRetryAll>(_onRetryAll);
    on<QueueSessionClearAll>(_onClearAll);

    _responseSub = RequestQueueManager().responseStream.listen(
      (response) {
        if (response.requestId.isNotEmpty) {
          add(QueueSessionItemUpdated(response));
        }
      },
    );
  }

  void _onItemUpdated(
    QueueSessionItemUpdated event,
    Emitter<QueueSessionState> emit,
  ) {
    final current = state.items[event.response.requestId];
    if (current == null) return;

    final updatedStatus = event.response.success
        ? QueueItemStatus.completed
        : QueueItemStatus.failed;

    final updatedItem = current.copyWith(
      item: current.item.copyWith(status: updatedStatus),
      lastResponse: event.response,
    );

    final updatedMap = Map<String, QueueSessionItem>.from(state.items)
      ..[event.response.requestId] = updatedItem;

    emit(state.copyWith(items: updatedMap));
  }

  Future<void> _onRetryAll(
    QueueSessionRetryAll event,
    Emitter<QueueSessionState> emit,
  ) async {
    // Reset all failed items in the UI state to processing
    final updatedItems = Map<String, QueueSessionItem>.from(state.items);
    bool changed = false;

    for (final id in updatedItems.keys) {
      final current = updatedItems[id]!;
      if (current.item.status == QueueItemStatus.failed) {
        updatedItems[id] = current.copyWith(
          item: current.item.copyWith(status: QueueItemStatus.processing),
        );
        changed = true;
      }
    }

    if (changed) {
      emit(state.copyWith(items: updatedItems));
    }

    await RequestQueueManager().retryAll();
  }

  Future<void> _onClearAll(
    QueueSessionClearAll event,
    Emitter<QueueSessionState> emit,
  ) async {
    await RequestQueueManager().clearAll();
    emit(state.copyWith(items: {}));
  }

  @override
  Future<void> close() async {
    await _responseSub.cancel();
    return super.close();
  }
}


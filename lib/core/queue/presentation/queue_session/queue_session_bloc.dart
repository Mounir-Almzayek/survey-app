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
                item: entry.value.copyWith(
                  status: QueueItemStatus.processing,
                ),
                lastResponse: null,
              ),
          },
        )) {
    on<QueueSessionItemUpdated>(_onItemUpdated);

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

  @override
  Future<void> close() async {
    await _responseSub.cancel();
    return super.close();
  }
}


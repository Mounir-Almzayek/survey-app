part of 'queue_session_bloc.dart';

abstract class QueueSessionEvent extends Equatable {
  const QueueSessionEvent();

  @override
  List<Object?> get props => [];
}

class QueueSessionItemUpdated extends QueueSessionEvent {
  final QueueResponse response;

  const QueueSessionItemUpdated(this.response);

  @override
  List<Object?> get props => [response];
}


import 'package:equatable/equatable.dart';

abstract class ActiveResponsesEvent extends Equatable {
  const ActiveResponsesEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveResponses extends ActiveResponsesEvent {}

class RemoveActiveResponse extends ActiveResponsesEvent {
  final String shortCode;
  const RemoveActiveResponse(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}

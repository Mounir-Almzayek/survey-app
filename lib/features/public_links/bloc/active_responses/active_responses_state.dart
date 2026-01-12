import 'package:equatable/equatable.dart';
import '../../models/public_link_active_response.dart';

abstract class ActiveResponsesState extends Equatable {
  const ActiveResponsesState();

  @override
  List<Object?> get props => [];
}

class ActiveResponsesInitial extends ActiveResponsesState {}

class ActiveResponsesLoading extends ActiveResponsesState {}

class ActiveResponsesSuccess extends ActiveResponsesState {
  final List<PublicLinkActiveResponse> responses;

  const ActiveResponsesSuccess(this.responses);

  @override
  List<Object?> get props => [responses];
}

class ActiveResponsesError extends ActiveResponsesState {
  final String message;

  const ActiveResponsesError(this.message);

  @override
  List<Object?> get props => [message];
}

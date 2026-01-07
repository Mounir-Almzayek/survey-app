part of 'response_details_bloc.dart';

abstract class ResponseDetailsEvent {}

class LoadResponseDetails extends ResponseDetailsEvent {
  final int responseId;
  final bool forceRefresh;

  LoadResponseDetails({required this.responseId, this.forceRefresh = false});
}

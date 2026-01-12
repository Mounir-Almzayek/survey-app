import 'package:equatable/equatable.dart';
import '../../models/save_section_answers_request.dart';
import '../../models/save_section_answers_response.dart';

/// States for Save Section Answers Bloc
abstract class SaveSectionAnswersState extends Equatable {
  final String shortCode;
  final int responseId;
  final int sectionId;
  final SaveSectionAnswersRequest request;

  const SaveSectionAnswersState({
    this.shortCode = '',
    this.responseId = 0,
    this.sectionId = 0,
    this.request = const SaveSectionAnswersRequest(answers: []),
  });

  @override
  List<Object?> get props => [shortCode, responseId, sectionId, request];
}

/// Initial state
class SaveSectionAnswersInitial extends SaveSectionAnswersState {
  const SaveSectionAnswersInitial({
    super.shortCode,
    super.responseId,
    super.sectionId,
    super.request,
  });
}

/// Loading state
class SaveSectionAnswersLoading extends SaveSectionAnswersState {
  const SaveSectionAnswersLoading({
    super.shortCode,
    super.responseId,
    super.sectionId,
    super.request,
  });
}

/// Success state
class SaveSectionAnswersSuccess extends SaveSectionAnswersState {
  final SaveSectionAnswersResponse response;

  const SaveSectionAnswersSuccess(
    this.response, {
    super.shortCode,
    super.responseId,
    super.sectionId,
    super.request,
  });

  @override
  List<Object?> get props => [response, ...super.props];
}

/// Local progress loaded state
class LocalProgressLoaded extends SaveSectionAnswersState {
  const LocalProgressLoaded({
    required super.request,
    super.shortCode,
    super.responseId,
    super.sectionId,
  });
}

/// Error state
class SaveSectionAnswersError extends SaveSectionAnswersState {
  final String message;

  const SaveSectionAnswersError(
    this.message, {
    super.shortCode,
    super.responseId,
    super.sectionId,
    super.request,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}

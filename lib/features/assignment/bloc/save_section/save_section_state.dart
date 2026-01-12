part of 'save_section_bloc.dart';

abstract class SaveSectionState {
  final int? responseId;
  final SaveSectionRequest? saveRequest;

  SaveSectionState({this.responseId, this.saveRequest});
}

class SaveSectionInitial extends SaveSectionState {
  SaveSectionInitial({super.responseId, super.saveRequest});
}

class SaveSectionLoading extends SaveSectionState {
  SaveSectionLoading({super.responseId, super.saveRequest});
}

class SaveSectionSuccess extends SaveSectionState {
  final SaveSectionResponse response;
  SaveSectionSuccess(this.response, {super.responseId, super.saveRequest});
}

class SaveSectionError extends SaveSectionState {
  final String message;
  SaveSectionError(this.message, {super.responseId, super.saveRequest});
}

import 'package:equatable/equatable.dart';

import '../../../../core/models/survey/survey_model.dart';

abstract class CreateShortLivedLinkEvent extends Equatable {
  const CreateShortLivedLinkEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the request with [survey.id] and language for the URL.
class InitializeShortLinkRequestFromSurvey extends CreateShortLivedLinkEvent {
  final Survey survey;

  const InitializeShortLinkRequestFromSurvey(this.survey);

  @override
  List<Object?> get props => [survey];
}

/// Request to create a link using [CreateShortLivedLinkState.request].
/// Location is captured at request time and appended to the URL.
class CreateShortLivedLinkRequested extends CreateShortLivedLinkEvent {
  const CreateShortLivedLinkRequested();
}

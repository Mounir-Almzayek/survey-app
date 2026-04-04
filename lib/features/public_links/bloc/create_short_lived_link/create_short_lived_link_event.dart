import 'package:equatable/equatable.dart';

import '../../../../core/models/survey/survey_model.dart';

abstract class CreateShortLivedLinkEvent extends Equatable {
  const CreateShortLivedLinkEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the request from survey (survey id + duration bounds from availabilityEndAt).
class InitializeShortLinkRequestFromSurvey extends CreateShortLivedLinkEvent {
  final Survey survey;

  const InitializeShortLinkRequestFromSurvey(this.survey);

  @override
  List<Object?> get props => [survey];
}

/// Update the survey id in the current request.
class UpdateShortLinkRequestSurveyId extends CreateShortLivedLinkEvent {
  final int surveyId;

  const UpdateShortLinkRequestSurveyId(this.surveyId);

  @override
  List<Object?> get props => [surveyId];
}

/// Update the duration in the current request ([minutes] sent to API; server sets expiry).
class UpdateShortLinkRequestDuration extends CreateShortLivedLinkEvent {
  final Duration duration;

  const UpdateShortLinkRequestDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Update the duration by minutes (convenience for UI).
class UpdateShortLinkRequestDurationMinutes extends CreateShortLivedLinkEvent {
  final int minutes;

  const UpdateShortLinkRequestDurationMinutes(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

/// Request to create a short-lived link using [CreateShortLivedLinkState.request].
/// Location is captured at request time and appended to the URL.
class CreateShortLivedLinkRequested extends CreateShortLivedLinkEvent {
  const CreateShortLivedLinkRequested();
}

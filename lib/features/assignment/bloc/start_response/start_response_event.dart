part of 'start_response_bloc.dart';

abstract class StartResponseEvent {}

class UpdateSurveyId extends StartResponseEvent {
  final int surveyId;
  UpdateSurveyId(this.surveyId);
}

class UpdateRequest extends StartResponseEvent {
  final StartResponseRequest request;
  UpdateRequest(this.request);
}

class UpdateGender extends StartResponseEvent {
  final Gender gender;
  UpdateGender(this.gender);
}

class UpdateAgeGroup extends StartResponseEvent {
  final AgeGroup ageGroup;
  UpdateAgeGroup(this.ageGroup);
}

class UpdateLocation extends StartResponseEvent {
  final Map<String, double>? location;
  UpdateLocation(this.location);
}

class StartSurveyResponse extends StartResponseEvent {
  StartSurveyResponse();
}

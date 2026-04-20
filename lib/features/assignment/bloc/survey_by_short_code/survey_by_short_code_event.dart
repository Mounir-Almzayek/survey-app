import 'package:equatable/equatable.dart';

sealed class SurveyByShortCodeEvent extends Equatable {
  const SurveyByShortCodeEvent();
  @override
  List<Object?> get props => const [];
}

class FetchSurvey extends SurveyByShortCodeEvent {
  final String shortCode;
  const FetchSurvey(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class RetrySurveyFetch extends SurveyByShortCodeEvent {
  const RetrySurveyFetch();
}

class ConnectivityRestored extends SurveyByShortCodeEvent {
  const ConnectivityRestored();
}

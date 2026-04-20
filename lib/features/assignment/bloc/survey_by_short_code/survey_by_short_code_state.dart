import 'package:equatable/equatable.dart';
import '../../../public_links/models/validated_public_link.dart';

enum SurveyFetchErrorKind { offline, notFound, serverError }

sealed class SurveyByShortCodeState extends Equatable {
  const SurveyByShortCodeState();
  @override
  List<Object?> get props => const [];
}

class SurveyByShortCodeIdle extends SurveyByShortCodeState {
  const SurveyByShortCodeIdle();
}

class SurveyByShortCodeLoading extends SurveyByShortCodeState {
  final String shortCode;
  const SurveyByShortCodeLoading(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class SurveyByShortCodeLoaded extends SurveyByShortCodeState {
  final String shortCode;
  final ValidatedPublicLink result;
  const SurveyByShortCodeLoaded(this.shortCode, this.result);
  @override
  List<Object?> get props => [shortCode, result];
}

class SurveyByShortCodeError extends SurveyByShortCodeState {
  final String shortCode;
  final SurveyFetchErrorKind kind;
  const SurveyByShortCodeError(this.shortCode, this.kind);
  @override
  List<Object?> get props => [shortCode, kind];
}

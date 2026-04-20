import 'package:equatable/equatable.dart';

class SurveyDeepLinkArgs extends Equatable {
  final String shortCode;

  const SurveyDeepLinkArgs({required this.shortCode});

  @override
  List<Object?> get props => [shortCode];
}

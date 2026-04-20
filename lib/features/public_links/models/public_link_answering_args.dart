import 'package:equatable/equatable.dart';

/// Navigation arguments for [PublicLinkAnsweringPage].
class PublicLinkAnsweringArgs extends Equatable {
  final String shortCode;
  final String surveyTitle;
  final bool requireLocation;

  const PublicLinkAnsweringArgs({
    required this.shortCode,
    required this.surveyTitle,
    required this.requireLocation,
  });

  @override
  List<Object?> get props => [shortCode, surveyTitle, requireLocation];
}

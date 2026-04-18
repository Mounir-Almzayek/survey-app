import 'package:equatable/equatable.dart';

import '../../models/create_short_lived_link_request.dart';

abstract class CreateShortLivedLinkState extends Equatable {
  const CreateShortLivedLinkState({
    this.request,
    this.surveyLanguage,
  });

  final CreateShortLivedLinkRequest? request;

  /// Survey language for URL generation
  final String? surveyLanguage;

  @override
  List<Object?> get props => [request, surveyLanguage];
}

class ShortLivedLinkInitial extends CreateShortLivedLinkState {
  const ShortLivedLinkInitial({
    super.request = const CreateShortLivedLinkRequest(),
    super.surveyLanguage,
  });
}

class ShortLivedLinkLoading extends CreateShortLivedLinkState {
  const ShortLivedLinkLoading({
    super.request,
    super.surveyLanguage,
  });
}

class ShortLivedLinkReady extends CreateShortLivedLinkState {
  final String fullUrl;
  final String shortCode;

  const ShortLivedLinkReady({
    required this.fullUrl,
    required this.shortCode,
    super.request,
    super.surveyLanguage,
  });

  @override
  List<Object?> get props => [
    fullUrl,
    shortCode,
    request,
    surveyLanguage,
  ];
}

class ShortLivedLinkError extends CreateShortLivedLinkState {
  final String message;

  const ShortLivedLinkError(
    this.message, {
    super.request,
    super.surveyLanguage,
  });

  @override
  List<Object?> get props => [message, request, surveyLanguage];
}

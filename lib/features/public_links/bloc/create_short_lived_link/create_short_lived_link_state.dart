import 'package:equatable/equatable.dart';

import '../../models/create_short_lived_link_request.dart';

abstract class CreateShortLivedLinkState extends Equatable {
  const CreateShortLivedLinkState({
    this.request,
    this.maxDurationMinutes,
    this.surveyLanguage,
  });

  final CreateShortLivedLinkRequest? request;

  /// Max duration in minutes (from survey.availabilityEndAt if set), null = no limit.
  final int? maxDurationMinutes;

  /// Survey language for URL generation
  final String? surveyLanguage;

  @override
  List<Object?> get props => [request, maxDurationMinutes, surveyLanguage];
}

class ShortLivedLinkInitial extends CreateShortLivedLinkState {
  const ShortLivedLinkInitial({
    super.request = const CreateShortLivedLinkRequest(),
    super.maxDurationMinutes,
    super.surveyLanguage,
  });
}

class ShortLivedLinkLoading extends CreateShortLivedLinkState {
  const ShortLivedLinkLoading({
    super.request,
    super.maxDurationMinutes,
    super.surveyLanguage,
  });
}

class ShortLivedLinkReady extends CreateShortLivedLinkState {
  final String fullUrl;
  final String shortCode;
  final DateTime? expiresAt;

  const ShortLivedLinkReady({
    required this.fullUrl,
    required this.shortCode,
    this.expiresAt,
    super.request,
    super.maxDurationMinutes,
    super.surveyLanguage,
  });

  @override
  List<Object?> get props => [
    fullUrl,
    shortCode,
    expiresAt,
    request,
    maxDurationMinutes,
    surveyLanguage,
  ];
}

class ShortLivedLinkError extends CreateShortLivedLinkState {
  final String message;

  const ShortLivedLinkError(
    this.message, {
    super.request,
    super.maxDurationMinutes,
    super.surveyLanguage,
  });

  @override
  List<Object?> get props => [
    message,
    request,
    maxDurationMinutes,
    surveyLanguage,
  ];
}

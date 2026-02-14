import 'package:equatable/equatable.dart';

import '../../models/create_short_lived_link_request.dart';

abstract class CreateShortLivedLinkState extends Equatable {
  const CreateShortLivedLinkState({this.request, this.maxDurationMinutes});

  final CreateShortLivedLinkRequest? request;
  /// Max duration in minutes (from survey.availabilityEndAt if set), null = no limit.
  final int? maxDurationMinutes;

  @override
  List<Object?> get props => [request, maxDurationMinutes];
}

class ShortLivedLinkInitial extends CreateShortLivedLinkState {
  const ShortLivedLinkInitial({
    super.request = const CreateShortLivedLinkRequest(),
    super.maxDurationMinutes,
  });
}

class ShortLivedLinkLoading extends CreateShortLivedLinkState {
  const ShortLivedLinkLoading({super.request, super.maxDurationMinutes});
}

class ShortLivedLinkReady extends CreateShortLivedLinkState {
  final String fullUrl;
  final String shortCode;
  final DateTime? expiresAt;

  const ShortLivedLinkReady({
    required this.fullUrl,
    required this.shortCode,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [fullUrl, shortCode, expiresAt];
}

class ShortLivedLinkError extends CreateShortLivedLinkState {
  final String message;

  const ShortLivedLinkError(this.message, {super.request, super.maxDurationMinutes});

  @override
  List<Object?> get props => [message, request];
}

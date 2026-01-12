import 'package:equatable/equatable.dart';
import '../../models/start_public_link_request.dart';
import '../../models/start_public_link_response.dart';

/// States for Start Public Link Bloc
abstract class StartPublicLinkState extends Equatable {
  final String shortCode;
  final StartPublicLinkRequest request;

  const StartPublicLinkState({
    this.shortCode = '',
    this.request = const StartPublicLinkRequest(),
  });

  @override
  List<Object?> get props => [shortCode, request];
}

/// Initial state
class StartPublicLinkInitial extends StartPublicLinkState {
  const StartPublicLinkInitial({super.shortCode, super.request});
}

/// Loading state
class StartPublicLinkLoading extends StartPublicLinkState {
  const StartPublicLinkLoading({super.shortCode, super.request});
}

/// Success state
class StartPublicLinkSuccess extends StartPublicLinkState {
  final StartPublicLinkResponse response;

  const StartPublicLinkSuccess(this.response, {super.shortCode, super.request});

  @override
  List<Object?> get props => [response, ...super.props];
}

/// Error state
class StartPublicLinkError extends StartPublicLinkState {
  final String message;

  const StartPublicLinkError(this.message, {super.shortCode, super.request});

  @override
  List<Object?> get props => [message, ...super.props];
}

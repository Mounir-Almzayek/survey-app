import 'package:equatable/equatable.dart';

import '../../models/validated_public_link.dart';

/// States for Validate Public Link Bloc
abstract class ValidatePublicLinkState extends Equatable {
  final String shortCode;

  const ValidatePublicLinkState({this.shortCode = ''});

  @override
  List<Object?> get props => [shortCode];
}

/// Initial state
class ValidatePublicLinkInitial extends ValidatePublicLinkState {
  const ValidatePublicLinkInitial({super.shortCode});
}

/// Loading state
class ValidatePublicLinkLoading extends ValidatePublicLinkState {
  const ValidatePublicLinkLoading({super.shortCode});
}

/// Validated state
class ValidatePublicLinkSuccess extends ValidatePublicLinkState {
  final ValidatedPublicLink link;

  const ValidatePublicLinkSuccess(this.link, {super.shortCode});

  @override
  List<Object?> get props => [link, ...super.props];
}

/// Error state
class ValidatePublicLinkError extends ValidatePublicLinkState {
  final String message;

  const ValidatePublicLinkError(this.message, {super.shortCode});

  @override
  List<Object?> get props => [message, ...super.props];
}

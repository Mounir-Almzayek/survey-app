import 'package:equatable/equatable.dart';
import '../../models/public_link.dart';

/// States for Validate Public Link Bloc
abstract class ValidatePublicLinkState extends Equatable {
  const ValidatePublicLinkState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ValidatePublicLinkInitial extends ValidatePublicLinkState {
  const ValidatePublicLinkInitial();
}

/// Loading state
class ValidatePublicLinkLoading extends ValidatePublicLinkState {
  const ValidatePublicLinkLoading();
}

/// Validated state
class ValidatePublicLinkSuccess extends ValidatePublicLinkState {
  final PublicLink link;

  const ValidatePublicLinkSuccess(this.link);

  @override
  List<Object?> get props => [link];
}

/// Error state
class ValidatePublicLinkError extends ValidatePublicLinkState {
  final String message;

  const ValidatePublicLinkError(this.message);

  @override
  List<Object?> get props => [message];
}


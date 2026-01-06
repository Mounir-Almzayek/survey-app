import 'package:equatable/equatable.dart';

/// Events for Validate Public Link Bloc
abstract class ValidatePublicLinkEvent extends Equatable {
  const ValidatePublicLinkEvent();

  @override
  List<Object?> get props => [];
}

/// Validate public link by short code
class ValidatePublicLink extends ValidatePublicLinkEvent {
  final String shortCode;

  const ValidatePublicLink(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}


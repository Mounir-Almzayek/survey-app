import 'package:equatable/equatable.dart';
import '../../models/validated_public_link.dart';

/// States for Visit Public Link Bloc
abstract class VisitPublicLinkState extends Equatable {
  final String shortCode;

  const VisitPublicLinkState({this.shortCode = ''});

  @override
  List<Object?> get props => [shortCode];
}

/// Initial state
class VisitPublicLinkInitial extends VisitPublicLinkState {
  const VisitPublicLinkInitial({super.shortCode});
}

/// Loading state
class VisitPublicLinkLoading extends VisitPublicLinkState {
  const VisitPublicLinkLoading({super.shortCode});
}

/// Success state
class VisitPublicLinkSuccess extends VisitPublicLinkState {
  final ValidatedPublicLink link;

  const VisitPublicLinkSuccess(this.link, {super.shortCode});

  @override
  List<Object?> get props => [link, ...super.props];
}

/// Error state
class VisitPublicLinkError extends VisitPublicLinkState {
  final String message;

  const VisitPublicLinkError(this.message, {super.shortCode});

  @override
  List<Object?> get props => [message, ...super.props];
}

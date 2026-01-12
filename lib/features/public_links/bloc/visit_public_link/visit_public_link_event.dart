import 'package:equatable/equatable.dart';

/// Events for Visit Public Link Bloc
abstract class VisitPublicLinkEvent extends Equatable {
  const VisitPublicLinkEvent();

  @override
  List<Object?> get props => [];
}

/// Visit public link by short code
class VisitPublicLink extends VisitPublicLinkEvent {
  final String shortCode;

  const VisitPublicLink(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}

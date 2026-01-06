import 'package:equatable/equatable.dart';

/// Events for Load Public Links Bloc
abstract class LoadPublicLinksEvent extends Equatable {
  const LoadPublicLinksEvent();

  @override
  List<Object?> get props => [];
}

/// Load public links
class LoadPublicLinks extends LoadPublicLinksEvent {
  final bool forceRefresh;

  const LoadPublicLinks({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Refresh public links
class RefreshPublicLinks extends LoadPublicLinksEvent {
  const RefreshPublicLinks();
}


import 'package:equatable/equatable.dart';
import '../../models/public_link.dart';

/// States for Load Public Links Bloc
abstract class LoadPublicLinksState extends Equatable {
  const LoadPublicLinksState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LoadPublicLinksInitial extends LoadPublicLinksState {
  const LoadPublicLinksInitial();
}

/// Loading state
class LoadPublicLinksLoading extends LoadPublicLinksState {
  const LoadPublicLinksLoading();
}

/// Loaded state
class LoadPublicLinksLoaded extends LoadPublicLinksState {
  final List<PublicLink> links;
  final bool isOffline;

  const LoadPublicLinksLoaded({
    required this.links,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [links, isOffline];
}

/// Error state
class LoadPublicLinksError extends LoadPublicLinksState {
  final String message;

  const LoadPublicLinksError(this.message);

  @override
  List<Object?> get props => [message];
}


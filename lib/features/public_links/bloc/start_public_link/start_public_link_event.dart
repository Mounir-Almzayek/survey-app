import 'package:equatable/equatable.dart';
import '../../models/start_public_link_request.dart';

/// Events for Start Public Link Bloc
abstract class StartPublicLinkEvent extends Equatable {
  const StartPublicLinkEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new response via public link
class StartPublicLinkResponseEvent extends StartPublicLinkEvent {
  final String shortCode;
  final StartPublicLinkRequest? request;

  const StartPublicLinkResponseEvent(this.shortCode, {this.request});

  @override
  List<Object?> get props => [shortCode, request];
}

import 'package:equatable/equatable.dart';

sealed class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();
  @override
  List<Object?> get props => const [];
}

class DeepLinkReceived extends DeepLinkEvent {
  final Uri uri;
  const DeepLinkReceived(this.uri);
  @override
  List<Object?> get props => [uri];
}

class ConfirmDiscardActiveSurvey extends DeepLinkEvent {
  final String shortCode;
  const ConfirmDiscardActiveSurvey(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class CancelDiscardActiveSurvey extends DeepLinkEvent {
  const CancelDiscardActiveSurvey();
}

class NavigationHandled extends DeepLinkEvent {
  const NavigationHandled();
}

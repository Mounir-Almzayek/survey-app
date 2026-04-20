import 'package:equatable/equatable.dart';

sealed class DeepLinkState extends Equatable {
  const DeepLinkState();
  @override
  List<Object?> get props => const [];
}

class DeepLinkIdle extends DeepLinkState {
  const DeepLinkIdle();
}

class NavigateToDeviceRegistration extends DeepLinkState {
  final String token;
  const NavigateToDeviceRegistration(this.token);
  @override
  List<Object?> get props => [token];
}

class NavigateToSurvey extends DeepLinkState {
  final String shortCode;
  const NavigateToSurvey(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class AwaitingDiscardConfirmation extends DeepLinkState {
  final String pendingShortCode;
  const AwaitingDiscardConfirmation(this.pendingShortCode);
  @override
  List<Object?> get props => [pendingShortCode];
}

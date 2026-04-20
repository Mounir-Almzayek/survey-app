import 'package:equatable/equatable.dart';

sealed class DeepLink extends Equatable {
  const DeepLink();
}

class RegisterDeviceLink extends DeepLink {
  final String token;
  const RegisterDeviceLink(this.token);
  @override
  List<Object?> get props => [token];
}

class SurveyLink extends DeepLink {
  final String shortCode;
  const SurveyLink(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class UnknownLink extends DeepLink {
  final Uri uri;
  const UnknownLink(this.uri);
  @override
  List<Object?> get props => [uri];
}

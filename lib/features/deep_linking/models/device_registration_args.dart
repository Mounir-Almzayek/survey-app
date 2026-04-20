import 'package:equatable/equatable.dart';

class DeviceRegistrationArgs extends Equatable {
  final String token;
  final bool fromDeepLink;

  const DeviceRegistrationArgs({
    required this.token,
    this.fromDeepLink = false,
  });

  @override
  List<Object?> get props => [token, fromDeepLink];
}

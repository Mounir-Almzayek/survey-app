import 'package:equatable/equatable.dart';
import '../../../../core/models/fingerprint.dart';

abstract class DeviceInfoState extends Equatable {
  const DeviceInfoState();

  @override
  List<Object?> get props => [];
}

class DeviceInfoInitial extends DeviceInfoState {}

class DeviceInfoLoading extends DeviceInfoState {}

class DeviceInfoLoaded extends DeviceInfoState {
  final Fingerprint fingerprint;

  const DeviceInfoLoaded(this.fingerprint);

  @override
  List<Object?> get props => [fingerprint];
}

class DeviceInfoError extends DeviceInfoState {
  final String message;

  const DeviceInfoError(this.message);

  @override
  List<Object?> get props => [message];
}


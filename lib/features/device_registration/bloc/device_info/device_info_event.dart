import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class DeviceInfoEvent extends Equatable {
  const DeviceInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeviceInfo extends DeviceInfoEvent {
  final BuildContext? context;

  const LoadDeviceInfo({this.context});

  @override
  List<Object?> get props => [context];
}


import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/device_info_util.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/models/fingerprint.dart';
import 'device_info_event.dart';
import 'device_info_state.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final AsyncRunner<Fingerprint> _deviceInfoRunner = AsyncRunner<Fingerprint>();

  DeviceInfoBloc() : super(DeviceInfoInitial()) {
    on<LoadDeviceInfo>(_onLoadDeviceInfo);
  }

  Future<void> _onLoadDeviceInfo(
    LoadDeviceInfo event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(DeviceInfoLoading());

    await _deviceInfoRunner.run(
      onlineTask: (_) async {
        return await DeviceInfoUtil.getFingerprintWithContext(event.context);
      },
      checkConnectivity: false,
      onSuccess: (fingerprint) {
        if (!emit.isDone) {
          emit(DeviceInfoLoaded(fingerprint));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(DeviceInfoError(error.toString()));
        }
      },
    );
  }
}

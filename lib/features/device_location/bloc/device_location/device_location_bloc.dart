import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/device_location.dart';
import '../../service/background_location_service.dart';
import '../../service/location_service.dart';
import 'device_location_event.dart';
import 'device_location_state.dart';

/// Bloc for managing device location tracking
class DeviceLocationBloc extends Bloc<DeviceLocationEvent, DeviceLocationState> {
  final AsyncRunner<void> _startTrackingRunner = AsyncRunner<void>();
  final AsyncRunner<DeviceLocation> _updateLocationRunner = AsyncRunner<DeviceLocation>();
  final BackgroundLocationService _backgroundService = BackgroundLocationService();
  StreamSubscription<DeviceLocation>? _locationSubscription;

  DeviceLocationBloc() : super(const DeviceLocationInitial()) {
    on<StartLocationTrackingEvent>(_onStartLocationTracking);
    on<StopLocationTrackingEvent>(_onStopLocationTracking);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
  }

  Future<void> _onStartLocationTracking(
    StartLocationTrackingEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    emit(const DeviceLocationLoading());

    await _startTrackingRunner.run(
      onlineTask: (_) async {
        // Check permissions
        final hasPermission = await LocationService.hasPermissions();
        if (!hasPermission) {
          final granted = await LocationService.requestPermissions();
          if (!granted) {
            throw Exception('Location permission denied');
          }
        }

        // Start background service
        await _backgroundService.start(
          deviceId: event.deviceId,
          assignmentId: event.assignmentId,
        );

        // Listen to location updates
        _locationSubscription?.cancel();
        _locationSubscription = LocationService.locationStream.listen(
          (location) {
            if (!emit.isDone) {
              add(const UpdateLocationEvent());
            }
          },
          onError: (error) {
            if (!emit.isDone) {
              emit(DeviceLocationError(error.toString()));
            }
          },
        );
      },
      checkConnectivity: false,
      onSuccess: (_) {
        if (!emit.isDone) {
          emit(const DeviceLocationTrackingStarted());
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          if (error.toString().toLowerCase().contains('permission')) {
            emit(const DeviceLocationPermissionDenied());
          } else {
            emit(DeviceLocationError(error.toString()));
          }
        }
      },
    );
  }

  Future<void> _onStopLocationTracking(
    StopLocationTrackingEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    await _backgroundService.stop();

    if (!emit.isDone) {
      emit(const DeviceLocationTrackingStopped());
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    await _updateLocationRunner.run(
      onlineTask: (_) async {
        return await LocationService.getCurrentLocation();
      },
      checkConnectivity: false,
      onSuccess: (location) {
        if (!emit.isDone) {
          emit(DeviceLocationUpdated(location));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          final errorMessage = error.toString().toLowerCase();
          if (errorMessage.contains('warning') ||
              errorMessage.contains('outside') ||
              errorMessage.contains('zone')) {
            emit(DeviceLocationWarningLogout(errorMessage));
          } else {
            emit(DeviceLocationUpdateFailed(error.toString()));
          }
        }
      },
    );
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    emit(const DeviceLocationLoading());

    final granted = await LocationService.requestPermissions();
    if (!emit.isDone) {
      if (granted) {
        emit(const DeviceLocationInitial());
      } else {
        emit(const DeviceLocationPermissionDenied());
      }
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _backgroundService.stop();
    LocationService.dispose();
    return super.close();
  }
}


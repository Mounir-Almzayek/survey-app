import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/device_local_metadata_service.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../features/auth/models/login_method_type.dart';
import '../../../../features/auth/repository/auth_local_repository.dart';
import '../../models/device_location.dart';
import '../../models/location_update_request.dart';
import '../../repository/device_location_local_repository.dart';
import '../../repository/device_location_online_repository.dart';
import '../../service/location_service.dart';
import 'device_location_event.dart';
import 'device_location_state.dart';

/// Bloc for managing device location tracking
class DeviceLocationBloc extends Bloc<DeviceLocationEvent, DeviceLocationState> {
  final AsyncRunner<DeviceLocationTrackingStarted?> _startTrackingRunner =
      AsyncRunner<DeviceLocationTrackingStarted?>();
  final DeviceLocalMetadataService _metadataService = DeviceLocalMetadataService();
  StreamSubscription<DeviceLocation>? _locationSubscription;

  DeviceLocationBloc() : super(const DeviceLocationInitial()) {
    on<StartLocationTrackingEvent>(_onStartLocationTracking);
    on<StopLocationTrackingEvent>(_onStopLocationTracking);
    on<RefreshAssignmentIdEvent>(_onRefreshAssignmentId);
    on<UpdateCoordinatesEvent>(_onUpdateCoordinates);
    on<RefreshDeviceIdEvent>(_onRefreshDeviceId);
    on<SendLocationEvent>(_onSendLocation);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<LocationStreamErrorEvent>(_onLocationStreamError);
  }

  Future<void> _onStartLocationTracking(
    StartLocationTrackingEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    // Idempotent: if already tracking, only refresh assignment_id (e.g. after starting another survey)
    final currentState = state;
    if (currentState is DeviceLocationTrackingStarted ||
        currentState is DeviceLocationUpdated) {
      add(const RefreshAssignmentIdEvent());
      return;
    }

    // Check context: need at least assignment_id or device_id to start
    final assignmentId = await _metadataService.getAssignmentId();
    final deviceId = await _resolveDeviceId();
    if (assignmentId == null && deviceId == null) {
      if (!emit.isDone) {
        emit(const DeviceLocationWaitingForContext());
      }
      return;
    }

    emit(const DeviceLocationLoading());

    await _startTrackingRunner.run(
      onlineTask: (_) async {
        final hasPermission = await LocationService.hasPermissions();
        if (!hasPermission) {
          final granted = await LocationService.requestPermissions();
          if (!granted) {
            throw Exception('Location permission denied');
          }
        }

        final assignmentId = await _metadataService.getAssignmentId();
        final deviceId = await _resolveDeviceId();

        final initialRequest = LocationUpdateRequest(
          latitude: 0,
          longitude: 0,
          deviceId: deviceId,
          assignmentId: assignmentId,
        );

        await LocationService.startLocationTracking();

        _locationSubscription?.cancel();
        _locationSubscription = LocationService.locationStream.listen(
          (location) {
            add(const RefreshAssignmentIdEvent());
            add(UpdateCoordinatesEvent(
              latitude: location.latitude,
              longitude: location.longitude,
            ));
            add(const RefreshDeviceIdEvent());
            add(const SendLocationEvent());
          },
          onError: (error) {
            add(LocationStreamErrorEvent(error.toString()));
          },
        );

        return DeviceLocationTrackingStarted(request: initialRequest);
      },
      checkConnectivity: false,
      onSuccess: (result) {
        if (!emit.isDone && result != null) {
          emit(result);
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

  /// Resolve deviceId from login method: challenge = deviceId from metadata, emailOnly = null
  Future<int?> _resolveDeviceId() async {
    final method = await AuthLocalRepository.getLoginMethod();
    if (method == LoginMethodType.challenge) {
      return _metadataService.getPhysicalDeviceId();
    }
    return null;
  }

  Future<void> _onStopLocationTracking(
    StopLocationTrackingEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    await LocationService.stopLocationTracking();

    if (!emit.isDone) {
      emit(const DeviceLocationTrackingStopped());
    }
  }

  Future<void> _onRefreshAssignmentId(
    RefreshAssignmentIdEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    final currentState = state;
    if (currentState.request == null) return;

    final assignmentId = await _metadataService.getAssignmentId();
    final updatedRequest = currentState.request!.copyWith(
      assignmentId: assignmentId,
      setAssignmentIdToNull: assignmentId == null,
    );

    if (!emit.isDone) {
      if (currentState is DeviceLocationTrackingStarted) {
        emit(currentState.copyWith(request: updatedRequest));
      } else if (currentState is DeviceLocationUpdated) {
        emit(DeviceLocationUpdated(currentState.location, request: updatedRequest));
      }
    }
  }

  Future<void> _onUpdateCoordinates(
    UpdateCoordinatesEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    final currentState = state;
    if (currentState.request == null) return;

    final updatedRequest = currentState.request!.copyWith(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    if (!emit.isDone) {
      if (currentState is DeviceLocationTrackingStarted) {
        emit(currentState.copyWith(request: updatedRequest));
      } else if (currentState is DeviceLocationUpdated) {
        emit(DeviceLocationUpdated(currentState.location, request: updatedRequest));
      }
    }
  }

  Future<void> _onRefreshDeviceId(
    RefreshDeviceIdEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    final currentState = state;
    if (currentState.request == null) return;

    final deviceId = await _resolveDeviceId();
    final updatedRequest = currentState.request!.copyWith(
      deviceId: deviceId,
      setDeviceIdToNull: deviceId == null,
    );

    if (!emit.isDone) {
      if (currentState is DeviceLocationTrackingStarted) {
        emit(currentState.copyWith(request: updatedRequest));
      } else if (currentState is DeviceLocationUpdated) {
        emit(DeviceLocationUpdated(currentState.location, request: updatedRequest));
      }
    }
  }

  Future<void> _onSendLocation(
    SendLocationEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    final currentState = state;
    final request = currentState.request;
    if (request == null) return;

    final token = await AuthLocalRepository.retrieveToken();
    if (token.isEmpty) return;

    // Backend requires either a valid device_id (with assignment/custody) or an unbounded assignment.
    // If we have neither, skip the API call to avoid 404 "Physical device not found".
    if (request.deviceId == null && request.assignmentId == null) {
      return;
    }

    final location = DeviceLocation(
      latitude: request.latitude,
      longitude: request.longitude,
      timestamp: DateTime.now(),
    );

    await DeviceLocationLocalRepository.saveLastLocation(location);

    try {
      await DeviceLocationOnlineRepository.updateDeviceLocation(
        request: request,
      );
      await DeviceLocationLocalRepository.removePendingLocation(location);
      if (!emit.isDone &&
          (currentState is DeviceLocationTrackingStarted ||
              currentState is DeviceLocationUpdated)) {
        emit(DeviceLocationUpdated(location, request: request));
      }
    } catch (e) {
      await DeviceLocationLocalRepository.savePendingLocation(location);
      if (!emit.isDone) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('warning') ||
            errorMessage.contains('outside') ||
            errorMessage.contains('zone')) {
          emit(DeviceLocationWarningLogout(errorMessage));
        } else {
          emit(DeviceLocationUpdateFailed(e.toString()));
        }
      }
    }
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

  Future<void> _onLocationStreamError(
    LocationStreamErrorEvent event,
    Emitter<DeviceLocationState> emit,
  ) async {
    if (!emit.isDone) {
      final errorLower = event.error.toLowerCase();
      if (errorLower.contains('permission')) {
        emit(const DeviceLocationPermissionDenied());
      } else {
        emit(DeviceLocationError(event.error));
      }
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    LocationService.stopLocationTracking();
    return super.close();
  }
}

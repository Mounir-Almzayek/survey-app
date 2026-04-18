import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/survey_enums.dart';
import '../../../../core/services/device_local_metadata_service.dart';
import '../../models/start_response_model.dart';
import '../../models/start_response_request_model.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/utils/transient_network_error.dart';

part 'start_response_event.dart';
part 'start_response_state.dart';

class StartResponseBloc extends Bloc<StartResponseEvent, StartResponseState> {
  final AsyncRunner<StartResponseResponse> _runner =
      AsyncRunner<StartResponseResponse>(
        maxRetryAttempts: 4,
        retryDelay: const Duration(milliseconds: 600),
        retryIf: isTransientNetworkFailure,
      );

  StartResponseBloc() : super(StartResponseInitial()) {
    on<UpdateSurveyId>(_onUpdateSurveyId);
    on<UpdateRequest>(_onUpdateRequest);
    on<UpdateGender>(_onUpdateGender);
    on<UpdateAgeGroup>(_onUpdateAgeGroup);
    on<UpdateLocation>(_onUpdateLocation);
    on<StartSurveyResponse>(_onStartResponse);
  }

  void _onUpdateSurveyId(
    UpdateSurveyId event,
    Emitter<StartResponseState> emit,
  ) {
    final currentRequest = state.request;
    final newRequest = StartResponseRequest(
      surveyId: event.surveyId,
      gender: currentRequest?.gender ?? Gender.male,
      ageGroup: currentRequest?.ageGroup ?? AgeGroup.age18_29,
      location: currentRequest?.location,
    );
    emit(StartResponseInitial(request: newRequest));
  }

  void _onUpdateRequest(UpdateRequest event, Emitter<StartResponseState> emit) {
    emit(StartResponseInitial(request: event.request));
  }

  void _onUpdateGender(UpdateGender event, Emitter<StartResponseState> emit) {
    final currentRequest = state.request;
    if (currentRequest != null) {
      final newRequest = currentRequest.copyWith(gender: event.gender);
      emit(StartResponseInitial(request: newRequest));
    }
  }

  void _onUpdateAgeGroup(
    UpdateAgeGroup event,
    Emitter<StartResponseState> emit,
  ) {
    final currentRequest = state.request;
    if (currentRequest != null) {
      final newRequest = currentRequest.copyWith(ageGroup: event.ageGroup);
      emit(StartResponseInitial(request: newRequest));
    }
  }

  void _onUpdateLocation(
    UpdateLocation event,
    Emitter<StartResponseState> emit,
  ) {
    final currentRequest = state.request;
    if (currentRequest != null) {
      final newRequest = currentRequest.copyWith(location: event.location);
      emit(StartResponseInitial(request: newRequest));
    }
  }

  Future<void> _onStartResponse(
    StartSurveyResponse event,
    Emitter<StartResponseState> emit,
  ) async {
    final request = state.request;
    if (request == null) {
      emit(StartResponseError("Request data is required", request: request));
      return;
    }

    final cachedSurvey = await AssignmentLocalRepository.getSurveyById(
      request.surveyId,
    );
    if (cachedSurvey != null && cachedSurvey.hasReachedMaxResponses) {
      if (!emit.isDone) {
        emit(
          StartResponseError(
            '',
            request: request,
            isMaxResponsesReached: true,
          ),
        );
      }
      return;
    }

    if (cachedSurvey != null &&
        cachedSurvey.isDemographicQuotaFull(request.gender, request.ageGroup)) {
      if (!emit.isDone) {
        emit(
          StartResponseError(
            '',
            request: request,
            isDemographicQuotaFull: true,
          ),
        );
      }
      return;
    }

    emit(StartResponseLoading(request: request));

    await _runner.run(
      onlineTask: (_) async =>
          await AssignmentRepository.startResponse(request),
      offlineTask: (_) async =>
          await AssignmentRepository.startResponseOffline(request),
      checkConnectivity: true,
      onSuccess: (response) async {
        // Link the new response ID to the survey in local storage
        await AssignmentLocalRepository.linkResponseToSurvey(
          request.surveyId,
          response.response.id,
        );
        // Link response id to demographic (who we're collecting for) for quota and UI
        await AssignmentLocalRepository.saveResponseMetadata(
          response.response.id,
          request.surveyId,
          request.gender,
          request.ageGroup,
        );
        // Persist assignment ID for location updates (last assignment interacted with)
        if (response.response.assignmentId != null) {
          await DeviceLocalMetadataService().saveAssignmentId(
            response.response.assignmentId,
          );
        }
        await AssignmentRepository.refreshCachedSurveyFromApi(request.surveyId);
        if (!emit.isDone) {
          emit(StartResponseSuccess(response, request: request));
        }
      },
      onOffline: (response) async {
        // Link the dummy response ID to the survey in local storage
        await AssignmentLocalRepository.linkResponseToSurvey(
          request.surveyId,
          response.response.id,
        );
        // Link response id to demographic (remapped to real id when start syncs)
        await AssignmentLocalRepository.saveResponseMetadata(
          response.response.id,
          request.surveyId,
          request.gender,
          request.ageGroup,
        );
        // Persist assignment ID for location updates (last assignment interacted with)
        if (response.response.assignmentId != null) {
          await DeviceLocalMetadataService().saveAssignmentId(
            response.response.assignmentId,
          );
        }
        if (!emit.isDone) {
          emit(StartResponseSuccess(response, request: request));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          final demoFull = _isDemographicQuotaApiError(error);
          final maxReached =
              !demoFull && _isMaxResponsesApiError(error);
          emit(
            StartResponseError(
              error is AppException ? error.message : error.toString(),
              request: request,
              isMaxResponsesReached: maxReached,
              isDemographicQuotaFull: demoFull,
            ),
          );
        }
      },
    );
  }

  static bool _isDemographicQuotaApiError(Object error) {
    if (error is! AppException) return false;
    final code = error.errorCode.toLowerCase();
    final msg = error.message.toLowerCase();
    if (code.contains('demographic') &&
        (code.contains('quota') || code.contains('full'))) {
      return true;
    }
    if (code.contains('category') && code.contains('quota')) {
      return true;
    }
    if (code.contains('quota') &&
        (code.contains('age') || code.contains('gender'))) {
      return true;
    }
    if (msg.contains('quota') &&
        (msg.contains('demographic') || msg.contains('category'))) {
      return true;
    }
    if (msg.contains('category') &&
        (msg.contains('full') || msg.contains('filled'))) {
      return true;
    }
    if (msg.contains('حصة') &&
        (msg.contains('فئة') || msg.contains('ديموغراف'))) {
      return true;
    }
    if (msg.contains('الفئة') && msg.contains('ممتل')) {
      return true;
    }
    return false;
  }

  static bool _isMaxResponsesApiError(Object error) {
    if (error is! AppException) return false;
    final code = error.errorCode.toLowerCase();
    if (code.contains('max') &&
        (code.contains('response') || code.contains('quota'))) {
      return true;
    }
    final msg = error.message.toLowerCase();
    return (msg.contains('max') && msg.contains('response')) ||
        msg.contains('maximum number of response') ||
        msg.contains('الحد الأقصى') && msg.contains('استجاب');
  }
}

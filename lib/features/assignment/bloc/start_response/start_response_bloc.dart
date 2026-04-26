import 'package:flutter_bloc/flutter_bloc.dart';
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
      location: currentRequest?.location,
    );
    emit(StartResponseInitial(request: newRequest));
  }

  void _onUpdateRequest(UpdateRequest event, Emitter<StartResponseState> emit) {
    emit(StartResponseInitial(request: event.request));
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

    // Demographic-quota pre-check removed: quota matching now happens
    // server-side at FINAL_SUBMIT.

    emit(StartResponseLoading(request: request));

    await _runner.run(
      onlineTask: (_) async =>
          await AssignmentRepository.startResponse(request),
      offlineTask: (_) async =>
          await AssignmentRepository.startResponseOffline(request),
      checkConnectivity: true,
      onSuccess: (response) async {
        await AssignmentLocalRepository.linkResponseToSurvey(
          request.surveyId,
          response.response.id,
        );
        // ResponseMetadata writes removed — quota tracking now keys off
        // Response.quotaTargetId resolved at FINAL_SUBMIT.
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
        await AssignmentLocalRepository.linkResponseToSurvey(
          request.surveyId,
          response.response.id,
        );
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
          final maxReached = _isMaxResponsesApiError(error);
          emit(
            StartResponseError(
              error is AppException ? error.message : error.toString(),
              request: request,
              isMaxResponsesReached: maxReached,
            ),
          );
        }
      },
    );
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

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/survey_enums.dart';
import '../../models/start_response_model.dart';
import '../../models/start_response_request_model.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/async_runner.dart';

part 'start_response_event.dart';
part 'start_response_state.dart';

class StartResponseBloc extends Bloc<StartResponseEvent, StartResponseState> {
  final AsyncRunner<StartResponseResponse> _runner =
      AsyncRunner<StartResponseResponse>();

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
        if (!emit.isDone) {
          emit(StartResponseSuccess(response, request: request));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(StartResponseError(error.toString(), request: request));
        }
      },
    );
  }
}

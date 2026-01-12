import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/save_section_models.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/async_runner.dart';

part 'save_section_event.dart';
part 'save_section_state.dart';

class SaveSectionBloc extends Bloc<SaveSectionEvent, SaveSectionState> {
  final AsyncRunner<SaveSectionResponse> _runner =
      AsyncRunner<SaveSectionResponse>();

  SaveSectionBloc() : super(SaveSectionInitial()) {
    on<UpdateResponseId>(_onUpdateResponseId);
    on<UpdateSaveSectionRequest>(_onUpdateSaveSectionRequest);
    on<UpdateAnswers>(_onUpdateAnswers);
    on<AddAnswer>(_onAddAnswer);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<RemoveAnswer>(_onRemoveAnswer);
    on<SubmitSection>(_onSaveSection);
  }

  Future<void> _onUpdateResponseId(
    UpdateResponseId event,
    Emitter<SaveSectionState> emit,
  ) async {
    // Check if there is a cached draft for this responseId
    final cachedDraft = await AssignmentLocalRepository.getResponseDraft(
      event.responseId,
    );

    if (cachedDraft != null) {
      emit(
        SaveSectionInitial(
          responseId: event.responseId,
          saveRequest: cachedDraft,
        ),
      );
    } else {
      // If no draft, create a blank model (sectionId: 0 as placeholder, will be updated)
      emit(
        SaveSectionInitial(
          responseId: event.responseId,
          saveRequest: SaveSectionRequest(sectionId: 0, answers: []),
        ),
      );
    }
  }

  Future<void> _onUpdateSaveSectionRequest(
    UpdateSaveSectionRequest event,
    Emitter<SaveSectionState> emit,
  ) async {
    emit(
      SaveSectionInitial(
        responseId: state.responseId,
        saveRequest: event.saveRequest,
      ),
    );
    await _autoSave();
  }

  Future<void> _onUpdateAnswers(
    UpdateAnswers event,
    Emitter<SaveSectionState> emit,
  ) async {
    final currentRequest = state.saveRequest;
    if (currentRequest != null) {
      final newRequest = currentRequest.copyWith(
        answers: event.answers,
        isSynced: false,
      );
      emit(
        SaveSectionInitial(
          responseId: state.responseId,
          saveRequest: newRequest,
        ),
      );
      await _autoSave();
    }
  }

  Future<void> _onAddAnswer(
    AddAnswer event,
    Emitter<SaveSectionState> emit,
  ) async {
    final currentRequest = state.saveRequest;
    if (currentRequest != null) {
      final newAnswers = List<AnswerRequest>.from(currentRequest.answers);
      newAnswers.removeWhere((a) => a.questionId == event.answer.questionId);
      newAnswers.add(event.answer);

      final newRequest = currentRequest.copyWith(
        answers: newAnswers,
        isSynced: false,
      );
      emit(
        SaveSectionInitial(
          responseId: state.responseId,
          saveRequest: newRequest,
        ),
      );
      await _autoSave();
    }
  }

  Future<void> _onUpdateAnswer(
    UpdateAnswer event,
    Emitter<SaveSectionState> emit,
  ) async {
    final currentRequest = state.saveRequest;
    if (currentRequest != null) {
      final newAnswers = List<AnswerRequest>.from(currentRequest.answers);
      final index = newAnswers.indexWhere(
        (a) => a.questionId == event.questionId,
      );

      if (index != -1) {
        newAnswers[index] = AnswerRequest(
          questionId: event.questionId,
          value: event.value,
        );
        final newRequest = currentRequest.copyWith(
          answers: newAnswers,
          isSynced: false,
        );
        emit(
          SaveSectionInitial(
            responseId: state.responseId,
            saveRequest: newRequest,
          ),
        );
        await _autoSave();
      }
    }
  }

  Future<void> _onRemoveAnswer(
    RemoveAnswer event,
    Emitter<SaveSectionState> emit,
  ) async {
    final currentRequest = state.saveRequest;
    if (currentRequest != null) {
      final newAnswers = List<AnswerRequest>.from(currentRequest.answers);
      newAnswers.removeWhere((a) => a.questionId == event.questionId);

      final newRequest = currentRequest.copyWith(
        answers: newAnswers,
        isSynced: false,
      );
      emit(
        SaveSectionInitial(
          responseId: state.responseId,
          saveRequest: newRequest,
        ),
      );
      await _autoSave();
    }
  }

  Future<void> _onSaveSection(
    SubmitSection event,
    Emitter<SaveSectionState> emit,
  ) async {
    final responseId = state.responseId;
    final saveRequest = state.saveRequest;

    if (responseId == null || saveRequest == null) {
      emit(
        SaveSectionError(
          "Response ID and Save Request are required",
          responseId: responseId,
          saveRequest: saveRequest,
        ),
      );
      return;
    }

    emit(SaveSectionLoading(responseId: responseId, saveRequest: saveRequest));

    await _runner.run(
      onlineTask: (_) async => await AssignmentRepository.saveSectionAnswers(
        responseId: responseId,
        saveRequest: saveRequest,
      ),
      offlineTask: (_) async {
        // 1. Enqueue the request via repository (marks as unsynced locally + adds to queue)
        await AssignmentRepository.enqueueSaveSectionAnswers(
          responseId: responseId,
          saveRequest: saveRequest,
        );

        return SaveSectionResponse(
          success: true,
          message: "Saved offline (queued)",
          isComplete: false,
          isQueued: true,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        if (!emit.isDone) {
          // The repository already updated the local draft to synced: true
          emit(
            SaveSectionSuccess(
              response,
              responseId: responseId,
              saveRequest: saveRequest.copyWith(isSynced: true),
            ),
          );
        }
      },
      onOffline: (response) {
        if (!emit.isDone) {
          emit(
            SaveSectionSuccess(
              response,
              responseId: responseId,
              saveRequest: saveRequest.copyWith(isSynced: false),
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            SaveSectionError(
              error.toString(),
              responseId: responseId,
              saveRequest: saveRequest,
            ),
          );
        }
      },
    );
  }

  /// Helper to auto-save current state to local storage
  Future<void> _autoSave() async {
    final responseId = state.responseId;
    final saveRequest = state.saveRequest;
    if (responseId != null && saveRequest != null) {
      await AssignmentLocalRepository.saveResponseDraft(
        responseId,
        saveRequest,
      );
    }
  }
}

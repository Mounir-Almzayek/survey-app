import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../models/save_section_answers_response.dart';
import '../../models/save_section_answers_request.dart';
import '../../repository/public_links_repository.dart';
import '../../repository/public_links_local_repository.dart';
import 'save_section_answers_event.dart';
import 'save_section_answers_state.dart';

/// Bloc for saving section answers
/// Uses AsyncRunner for all operations and supports offline memory
class SaveSectionAnswersBloc
    extends Bloc<SaveSectionAnswersEvent, SaveSectionAnswersState> {
  final AsyncRunner<SaveSectionAnswersResponse> _saveAnswersRunner =
      AsyncRunner<SaveSectionAnswersResponse>();

  SaveSectionAnswersBloc() : super(const SaveSectionAnswersInitial()) {
    on<InitializeSection>(_onInitializeSection);
    on<UpdateAnswers>(_onUpdateAnswers);
    on<SaveSectionAnswers>(_onSaveSectionAnswers);
  }

  Future<void> _onInitializeSection(
    InitializeSection event,
    Emitter<SaveSectionAnswersState> emit,
  ) async {
    emit(
      SaveSectionAnswersLoading(
        shortCode: event.shortCode,
        responseId: event.responseId,
        sectionId: event.sectionId,
        request: state.request,
      ),
    );

    // Try to load existing progress from local memory
    final progress = await PublicLinksRepository.getSectionProgress(
      shortCode: event.shortCode,
      responseId: event.responseId,
      sectionId: event.sectionId,
    );

    if (!emit.isDone) {
      if (progress != null) {
        emit(
          LocalProgressLoaded(
            request: progress,
            shortCode: event.shortCode,
            responseId: event.responseId,
            sectionId: event.sectionId,
          ),
        );
      } else {
        // No progress found, initialize with empty request
        emit(
          SaveSectionAnswersInitial(
            shortCode: event.shortCode,
            responseId: event.responseId,
            sectionId: event.sectionId,
            request: const SaveSectionAnswersRequest(answers: []),
          ),
        );
      }
    }
  }

  Future<void> _onUpdateAnswers(
    UpdateAnswers event,
    Emitter<SaveSectionAnswersState> emit,
  ) async {
    final updatedRequest = event.request.copyWith(isSynced: false);

    emit(
      SaveSectionAnswersInitial(
        shortCode: state.shortCode,
        responseId: state.responseId,
        sectionId: state.sectionId,
        request: updatedRequest,
      ),
    );

    // Persist intermediate progress to local memory
    await PublicLinksLocalRepository.saveSectionAnswersRequest(
      shortCode: state.shortCode,
      responseId: state.responseId,
      sectionId: state.sectionId,
      request: updatedRequest,
    );
  }

  Future<void> _onSaveSectionAnswers(
    SaveSectionAnswers event,
    Emitter<SaveSectionAnswersState> emit,
  ) async {
    final currentShortCode = state.shortCode;
    final currentResponseId = state.responseId;
    final currentSectionId = state.sectionId;
    final currentRequest = state.request;

    if (currentShortCode.isEmpty ||
        currentResponseId == 0 ||
        currentSectionId == 0) {
      return;
    }

    emit(
      SaveSectionAnswersLoading(
        shortCode: currentShortCode,
        responseId: currentResponseId,
        sectionId: currentSectionId,
        request: currentRequest,
      ),
    );

    await _saveAnswersRunner.run(
      onlineTask: (_) async {
        return await PublicLinksRepository.saveSectionAnswers(
          shortCode: currentShortCode,
          responseId: currentResponseId,
          sectionId: currentSectionId,
          request: currentRequest,
        );
      },
      offlineTask: (_) async {
        await PublicLinksRepository.enqueueSaveSectionAnswers(
          shortCode: currentShortCode,
          responseId: currentResponseId,
          sectionId: currentSectionId,
          request: currentRequest,
        );

        // Determine next section locally for offline continuity
        return await PublicLinksRepository.getNextSectionOffline(
          shortCode: currentShortCode,
          sectionId: currentSectionId,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) async {
        if (response.isComplete) {
          await PublicLinksLocalRepository.removeActiveResponse(
            currentShortCode,
          );
        } else if (response.nextSection != null) {
          final activeResponses =
              await PublicLinksLocalRepository.getActiveResponses();
          final currentActive = activeResponses
              .where((r) => r.shortCode == currentShortCode)
              .firstOrNull;

          if (currentActive != null) {
            await PublicLinksLocalRepository.saveActiveResponse(
              currentActive.copyWith(
                lastSectionId: response.nextSection!.id,
                updatedAt: DateTime.now(),
              ),
            );
          }
        }

        if (!emit.isDone) {
          emit(
            SaveSectionAnswersSuccess(
              response,
              shortCode: currentShortCode,
              responseId: currentResponseId,
              sectionId: currentSectionId,
              request: currentRequest.copyWith(isSynced: true),
            ),
          );
        }
      },
      onOffline: (response) {
        if (!emit.isDone) {
          emit(
            SaveSectionAnswersSuccess(
              response,
              shortCode: currentShortCode,
              responseId: currentResponseId,
              sectionId: currentSectionId,
              request: currentRequest.copyWith(isSynced: false),
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            SaveSectionAnswersError(
              error.toString(),
              shortCode: currentShortCode,
              responseId: currentResponseId,
              sectionId: currentSectionId,
              request: currentRequest.copyWith(isSynced: false),
            ),
          );
        }
      },
    );
  }
}

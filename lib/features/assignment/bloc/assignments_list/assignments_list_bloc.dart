import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/assignment_response_model.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/models/survey/survey_model.dart';

part 'assignments_list_event.dart';
part 'assignments_list_state.dart';

class AssignmentsListBloc
    extends Bloc<AssignmentsListEvent, AssignmentsListState> {
  final AsyncRunner<ListAssignmentsResponse> _runner =
      AsyncRunner<ListAssignmentsResponse>();

  AssignmentsListBloc() : super(AssignmentsListInitial()) {
    on<LoadAssignments>(_onLoadAssignments);
    on<SearchAssignments>(_onSearchAssignments);
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
    on<AddToHistory>(_onAddToHistory);
    on<ClearAssignmentsList>(_onClearAssignmentsList);
  }

  Future<void> _onAddToHistory(
    AddToHistory event,
    Emitter<AssignmentsListState> emit,
  ) async {
    if (event.query.trim().isNotEmpty) {
      await AssignmentLocalRepository.addToSearchHistory(event.query);
      if (state is AssignmentsListLoaded) {
        final history = await AssignmentLocalRepository.getSearchHistory();
        emit((state as AssignmentsListLoaded).copyWith(recentSearches: history));
      }
    }
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<AssignmentsListState> emit,
  ) async {
    if (state is AssignmentsListLoaded) {
      final history = await AssignmentLocalRepository.getSearchHistory();
      emit((state as AssignmentsListLoaded).copyWith(recentSearches: history));
    }
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<AssignmentsListState> emit,
  ) async {
    await AssignmentLocalRepository.clearSearchHistory();
    if (state is AssignmentsListLoaded) {
      emit((state as AssignmentsListLoaded).copyWith(recentSearches: []));
    }
  }

  Future<void> _onSearchAssignments(
    SearchAssignments event,
    Emitter<AssignmentsListState> emit,
  ) async {
    if (state is AssignmentsListLoaded) {
      final currentState = state as AssignmentsListLoaded;
      final query = event.query.toLowerCase().trim();

      final history = await AssignmentLocalRepository.getSearchHistory();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredSurveys: currentState.response.surveys,
            searchQuery: '',
            recentSearches: history,
          ),
        );
      } else {
        final filtered = currentState.response.surveys.where((survey) {
          final titleMatch = (survey.title ?? '').toLowerCase().contains(query);
          final descMatch = (survey.description ?? '').toLowerCase().contains(
            query,
          );
          return titleMatch || descMatch;
        }).toList();

        emit(
          currentState.copyWith(
            filteredSurveys: filtered,
            searchQuery: event.query,
            recentSearches: history,
          ),
        );
      }
    }
  }

  void _onClearAssignmentsList(
    ClearAssignmentsList event,
    Emitter<AssignmentsListState> emit,
  ) {
    emit(AssignmentsListInitial());
  }

  Future<void> _onLoadAssignments(
    LoadAssignments event,
    Emitter<AssignmentsListState> emit,
  ) async {
    emit(AssignmentsListLoading());

    final history = await AssignmentLocalRepository.getSearchHistory();

    await _runner.run(
      onlineTask: (_) async => await AssignmentRepository.listAssignments(),
      offlineTask: (_) async {
        final local = await AssignmentLocalRepository.getSurveys();
        if (local.isEmpty) throw Exception("No offline data available");
        final activeSurveys = local.where((s) => s.isActive).toList();
        return ListAssignmentsResponse(
          success: true,
          message: "Loaded from cache",
          surveys: activeSurveys,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) async {
        await AssignmentLocalRepository.saveSurveys(response.surveys);
        final localSurveys = await AssignmentLocalRepository.getSurveys();
        if (!emit.isDone) {
          emit(
            AssignmentsListLoaded(
              ListAssignmentsResponse(
                success: response.success,
                message: response.message,
                surveys: localSurveys,
              ),
              recentSearches: history,
            ),
          );
        }
      },
      onOffline: (response) {
        if (!emit.isDone) {
          emit(AssignmentsListLoaded(response, recentSearches: history));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(AssignmentsListError(error.toString()));
        }
      },
    );
  }
}

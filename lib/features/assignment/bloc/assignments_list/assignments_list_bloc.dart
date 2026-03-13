import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/assignment_response_model.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/async_runner.dart';

part 'assignments_list_event.dart';
part 'assignments_list_state.dart';

class AssignmentsListBloc
    extends Bloc<AssignmentsListEvent, AssignmentsListState> {
  final AsyncRunner<ListAssignmentsResponse> _runner =
      AsyncRunner<ListAssignmentsResponse>();

  AssignmentsListBloc() : super(AssignmentsListInitial()) {
    on<LoadAssignments>(_onLoadAssignments);
    on<ClearAssignmentsList>(_onClearAssignmentsList);
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
            ),
          );
        }
      },
      onOffline: (response) {
        if (!emit.isDone) {
          emit(AssignmentsListLoaded(response));
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

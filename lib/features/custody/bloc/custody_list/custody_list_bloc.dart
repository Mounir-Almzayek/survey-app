import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/custody_record.dart';
import '../../repository/custody_online_repository.dart';
import '../../repository/custody_local_repository.dart';
import 'custody_list_event.dart';
import 'custody_list_state.dart';

/// Bloc for loading custody records
/// Uses AsyncRunner for all operations
class CustodyListBloc extends Bloc<CustodyListEvent, CustodyListState> {
  final AsyncRunner<List<CustodyRecord>> _loadRecordsRunner =
      AsyncRunner<List<CustodyRecord>>();

  CustodyListBloc() : super(const CustodyListInitial()) {
    on<LoadCustodyRecords>(_onLoadCustodyRecords);
    on<RefreshCustodyRecords>(_onRefreshCustodyRecords);
  }

  Future<void> _onLoadCustodyRecords(
    LoadCustodyRecords event,
    Emitter<CustodyListState> emit,
  ) async {
    if (!event.forceRefresh) {
      // Try to load from local first
      final localRecords = await CustodyLocalRepository.getCustodyRecords();
      if (localRecords.isNotEmpty) {
        emit(CustodyListLoaded(records: localRecords, isOffline: true));
      }
    }

    emit(const CustodyListLoading());

    await _loadRecordsRunner.run(
      onlineTask: (_) async {
        return await CustodyOnlineRepository.getCustodyRecords();
      },
      offlineTask: (_) async {
        final records = await CustodyLocalRepository.getCustodyRecords();
        if (records.isEmpty) {
          throw Exception('No local data available');
        }
        return records;
      },
      checkConnectivity: true,
      onSuccess: (records) async {
        // Save to local storage
        await CustodyLocalRepository.saveCustodyRecords(records);

        if (!emit.isDone) {
          emit(CustodyListLoaded(records: records, isOffline: false));
        }
      },
      onOffline: (records) {
        if (!emit.isDone) {
          emit(CustodyListLoaded(records: records, isOffline: true));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CustodyListError(error.toString()));
        }
      },
    );
  }

  Future<void> _onRefreshCustodyRecords(
    RefreshCustodyRecords event,
    Emitter<CustodyListState> emit,
  ) async {
    add(const LoadCustodyRecords(forceRefresh: true));
  }

  @override
  Future<void> close() {
    _loadRecordsRunner.cancel();
    return super.close();
  }
}


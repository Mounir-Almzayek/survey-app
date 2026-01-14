import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/custody_record.dart';
import '../../repository/custody_online_repository.dart';
import '../../repository/custody_local_repository.dart';
import 'custody_list_event.dart';
import 'custody_list_state.dart';

import '../../../../core/utils/paginated_manager.dart';
import '../../models/custody_list_request.dart';

/// Bloc for loading custody records
/// Uses AsyncRunner for all operations and PaginatedManager for infinite scrolling
class CustodyListBloc extends Bloc<CustodyListEvent, CustodyListState> {
  final AsyncRunner<List<CustodyRecord>> _loadRecordsRunner =
      AsyncRunner<List<CustodyRecord>>();
  final PaginatedManager<CustodyRecord> _paginatedManager =
      PaginatedManager<CustodyRecord>(pageSize: 10);

  CustodyListBloc() : super(const CustodyListInitial()) {
    on<LoadCustodyRecords>(_onLoadCustodyRecords);
    on<RefreshCustodyRecords>(_onRefreshCustodyRecords);
    on<LoadNextPage>(_onLoadNextPage);
  }

  Future<void> _onLoadCustodyRecords(
    LoadCustodyRecords event,
    Emitter<CustodyListState> emit,
  ) async {
    if (!event.forceRefresh && event.request == null) {
      // Try to load from local first
      final localRecords = await CustodyLocalRepository.getCustodyRecords();
      if (localRecords.isNotEmpty) {
        // Sync PaginatedManager with local data to allow seamless transition if online
        _paginatedManager.data = List.from(localRecords);
        // We assume local records are the first N pages, so we can't easily set currentPage
        // but for now, we just emit the state.
        emit(
          CustodyListLoaded(
            records: localRecords,
            isOffline: true,
            hasMoreData: false,
          ),
        );
      }
    }

    if (event.forceRefresh || event.request != null) {
      _paginatedManager.resetPagination();
    }

    if (_paginatedManager.currentPage == 1) {
      emit(const CustodyListLoading());
    } else {
      if (state is CustodyListLoaded) {
        emit((state as CustodyListLoaded).copyWith(isFetchingMore: true));
      }
    }

    await _loadRecordsRunner.run(
      onlineTask: (_) async {
        final request = (event.request ?? const CustodyListRequest()).copyWith(
          page: _paginatedManager.currentPage,
          pageSize: _paginatedManager.pageSize,
        );
        return await CustodyOnlineRepository.getCustodyRecords(request);
      },
      offlineTask: (_) async {
        if (_paginatedManager.currentPage > 1) return [];
        final records = await CustodyLocalRepository.getCustodyRecords();
        if (records.isEmpty) {
          throw Exception('No local data available');
        }
        return records;
      },
      checkConnectivity: true,
      onSuccess: (records) async {
        final isFirstPage = _paginatedManager.currentPage == 1;

        if (isFirstPage) {
          // Smart offline: clear all and save first page
          await CustodyLocalRepository.clearCustodyRecords();
          await CustodyLocalRepository.saveCustodyRecords(records);
        } else {
          // Smart offline: append subsequent pages
          await CustodyLocalRepository.appendCustodyRecords(records);
        }

        await _paginatedManager.loadPage(
          task: (page, pageSize) async => records,
        );

        if (!emit.isDone) {
          emit(
            CustodyListLoaded(
              records: _paginatedManager.data,
              isOffline: false,
              hasMoreData: _paginatedManager.hasMoreData,
            ),
          );
        }
      },
      onOffline: (records) {
        if (!emit.isDone) {
          emit(
            CustodyListLoaded(
              records: records,
              isOffline: true,
              hasMoreData: false,
            ),
          );
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
    add(LoadCustodyRecords(forceRefresh: true, request: event.request));
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<CustodyListState> emit,
  ) async {
    if (!_paginatedManager.hasMoreData || state is CustodyListLoading) return;
    add(LoadCustodyRecords(forceRefresh: false, request: event.request));
  }

  @override
  Future<void> close() {
    _loadRecordsRunner.cancel();
    return super.close();
  }
}

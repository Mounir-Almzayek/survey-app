import 'package:equatable/equatable.dart';

import '../../models/custody_list_request.dart';

/// Events for Custody List Bloc
abstract class CustodyListEvent extends Equatable {
  const CustodyListEvent();

  @override
  List<Object?> get props => [];
}

/// Load custody records
class LoadCustodyRecords extends CustodyListEvent {
  final bool forceRefresh;
  final CustodyListRequest? request;

  const LoadCustodyRecords({this.forceRefresh = false, this.request});

  @override
  List<Object?> get props => [forceRefresh, request];
}

/// Refresh custody records
class RefreshCustodyRecords extends CustodyListEvent {
  final CustodyListRequest? request;

  const RefreshCustodyRecords({this.request});

  @override
  List<Object?> get props => [request];
}

/// Load next page of custody records
class LoadNextPage extends CustodyListEvent {
  final CustodyListRequest? request;

  const LoadNextPage({this.request});

  @override
  List<Object?> get props => [request];
}

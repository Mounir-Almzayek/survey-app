import 'package:equatable/equatable.dart';

/// Events for Custody List Bloc
abstract class CustodyListEvent extends Equatable {
  const CustodyListEvent();

  @override
  List<Object?> get props => [];
}

/// Load custody records
class LoadCustodyRecords extends CustodyListEvent {
  final bool forceRefresh;

  const LoadCustodyRecords({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Refresh custody records
class RefreshCustodyRecords extends CustodyListEvent {
  const RefreshCustodyRecords();
}


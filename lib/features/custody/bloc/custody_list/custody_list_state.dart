import 'package:equatable/equatable.dart';
import '../../models/custody_record.dart';

/// States for Custody List Bloc
abstract class CustodyListState extends Equatable {
  const CustodyListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CustodyListInitial extends CustodyListState {
  const CustodyListInitial();
}

/// Loading state
class CustodyListLoading extends CustodyListState {
  const CustodyListLoading();
}

/// Loaded state
class CustodyListLoaded extends CustodyListState {
  final List<CustodyRecord> records;
  final bool isOffline;
  final bool hasMoreData;
  final bool isFetchingMore;

  const CustodyListLoaded({
    required this.records,
    this.isOffline = false,
    this.hasMoreData = false,
    this.isFetchingMore = false,
  });

  @override
  List<Object?> get props => [records, isOffline, hasMoreData, isFetchingMore];

  CustodyListLoaded copyWith({
    List<CustodyRecord>? records,
    bool? isOffline,
    bool? hasMoreData,
    bool? isFetchingMore,
  }) {
    return CustodyListLoaded(
      records: records ?? this.records,
      isOffline: isOffline ?? this.isOffline,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

/// Error state
class CustodyListError extends CustodyListState {
  final String message;

  const CustodyListError(this.message);

  @override
  List<Object?> get props => [message];
}

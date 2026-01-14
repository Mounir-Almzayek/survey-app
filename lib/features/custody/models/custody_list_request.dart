import 'package:equatable/equatable.dart';

/// Request model for fetching custody records with filters
class CustodyListRequest extends Equatable {
  final int? page;
  final int? pageSize;
  final String? search;
  final String? status; // pending, verified, cancelled
  final DateTime? startDate;
  final DateTime? endDate;
  final int? physicalDeviceId;

  const CustodyListRequest({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.status,
    this.startDate,
    this.endDate,
    this.physicalDeviceId,
  });

  /// Convert to query parameters for API
  Map<String, String> toQueryParameters() {
    final query = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
      if (search != null && search!.isNotEmpty) 'search': search!,
      if (physicalDeviceId != null)
        'physical_device_id': physicalDeviceId.toString(),
    };

    // Handle status filtering based on backend logic
    // Since the backend uses Prisma and getDataHandler, we can send filters in 'where' format if needed,
    // but usually, simple filters are passed directly.
    if (status != null) {
      if (status == 'verified') {
        query['verified_at[not]'] = 'null';
      } else if (status == 'pending') {
        query['verified_at'] = 'null';
      }
    }

    // Date filters
    if (startDate != null) {
      query['created_at[gte]'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      query['created_at[lte]'] = endDate!.toIso8601String();
    }

    return query;
  }

  CustodyListRequest copyWith({
    int? page,
    int? pageSize,
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? physicalDeviceId,
  }) {
    return CustodyListRequest(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      physicalDeviceId: physicalDeviceId ?? this.physicalDeviceId,
    );
  }

  @override
  List<Object?> get props => [
    page,
    pageSize,
    search,
    status,
    startDate,
    endDate,
    physicalDeviceId,
  ];
}

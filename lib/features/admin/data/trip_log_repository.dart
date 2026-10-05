// features/admin/data/trip_log_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/admin_trip_model.dart';

/// One page of the trip log, plus how many rows match the filter overall.
class TripLogPage {
  final List<AdminTripModel> trips;
  final int total;
  final int limit;
  final int offset;

  const TripLogPage({
    required this.trips,
    required this.total,
    required this.limit,
    required this.offset,
  });

  bool get hasMore => offset + trips.length < total;
  int get page => limit == 0 ? 1 : (offset ~/ limit) + 1;
  int get pageCount => limit == 0 ? 1 : ((total + limit - 1) ~/ limit).clamp(1, 9999);
}

/// What the log is filtered by. Used as the provider's family argument, so
/// it needs value equality — two identical filters must not refetch.
class TripLogFilter {
  final String? status;
  final String? departmentId;
  final String search;
  final DateTime? from;
  final DateTime? to;
  final int limit;
  final int offset;

  const TripLogFilter({
    this.status,
    this.departmentId,
    this.search = '',
    this.from,
    this.to,
    this.limit = 25,
    this.offset = 0,
  });

  TripLogFilter copyWith({
    String? status,
    String? departmentId,
    String? search,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
    bool clearStatus = false,
    bool clearDepartment = false,
    bool clearDates = false,
  }) {
    return TripLogFilter(
      status: clearStatus ? null : (status ?? this.status),
      departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
      search: search ?? this.search,
      from: clearDates ? null : (from ?? this.from),
      to: clearDates ? null : (to ?? this.to),
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  String get query {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (status != null) 'status': status!,
      if (departmentId != null) 'departmentId': departmentId!,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (from != null) 'from': from!.toUtc().toIso8601String(),
      if (to != null) 'to': to!.toUtc().toIso8601String(),
    };
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }

  @override
  bool operator ==(Object other) =>
      other is TripLogFilter &&
          other.status == status &&
          other.departmentId == departmentId &&
          other.search == search &&
          other.from == from &&
          other.to == to &&
          other.limit == limit &&
          other.offset == offset;

  @override
  int get hashCode =>
      Object.hash(status, departmentId, search, from, to, limit, offset);
}

class TripLogRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  TripLogRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<TripLogPage> getTrips(TripLogFilter filter) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/trips?${filter.query}',
        accessToken: token);
    final list = response['trips'] as List<dynamic>? ?? [];
    return TripLogPage(
      trips: list
          .map((e) => AdminTripModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (response['total'] as num?)?.toInt() ?? 0,
      limit: (response['limit'] as num?)?.toInt() ?? filter.limit,
      offset: (response['offset'] as num?)?.toInt() ?? filter.offset,
    );
  }
}
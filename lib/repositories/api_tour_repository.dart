import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../data/json_codec.dart';
import '../models/page_result.dart';
import '../models/tour.dart';
import '../models/tour_query.dart';
import 'tour_repository.dart';

Map<String, dynamic> asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

PageResult<T> parsePage<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromJson, {
  int fallbackSize = 10,
}) {
  final map = asJsonMap(data);
  return PageResult(
    items: [
      for (final item in (map['items'] as List? ?? []))
        if (item is Map) fromJson(Map<String, dynamic>.from(item)),
    ],
    page: jsonInt(map['page'], 1),
    size: jsonInt(map['size'], fallbackSize),
    total: jsonInt(map['total']),
  );
}

Future<List<T>> fetchAllRecords<T>(
  Dio dio,
  String path,
  T Function(Map<String, dynamic>) fromJson, {
  bool includeDeleted = false,
}) async {
  Future<List<T>> load({required bool onlyDeleted}) async {
    final response = await dio.get<dynamic>(
      path,
      queryParameters: {
        'size': 200,
        'page': 1,
        if (onlyDeleted) 'includeDeleted': true,
      },
    );
    return parsePage(response.data, fromJson).items;
  }

  final active = await load(onlyDeleted: false);
  if (!includeDeleted) return active;
  return [...active, ...await load(onlyDeleted: true)];
}

Future<int> fetchFilteredTotal(
  Dio dio,
  String path,
  Map<String, dynamic> extra,
) async {
  Future<int> total({required bool onlyDeleted}) async {
    final response = await dio.get<dynamic>(
      path,
      queryParameters: {
        ...extra,
        'size': 1,
        'page': 1,
        if (onlyDeleted) 'includeDeleted': true,
      },
    );
    return jsonInt(asJsonMap(response.data)['total']);
  }

  return await total(onlyDeleted: false) + await total(onlyDeleted: true);
}

class ApiTourRepository implements TourRepository {
  ApiTourRepository(this._dio);

  final Dio _dio;
  CancelToken? _findToken;

  Map<String, dynamic> _body(Tour tour) => {
    'title': tour.title,
    'code': tour.code,
    'year': tour.year,
    'durationDays': tour.durationDays,
    'destinationId': tour.destinationId,
    'hotelIds': tour.hotelIds,
    'categoryIds': tour.categoryIds,
    'seatsTotal': tour.seatsTotal,
    'seatsAvailable': tour.seatsAvailable,
    'price': tour.price,
  };

  @override
  Future<PageResult<Tour>> find(TourQuery q) {
    _findToken?.cancel();
    _findToken = CancelToken();
    final token = _findToken!;
    return guardRead(() async {
      final response = await _dio.get<dynamic>(
        '/tours',
        queryParameters: listQuery(
          search: q.search,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          page: q.page,
          size: q.size,
          includeDeleted: q.includeDeleted,
          extra: {
            if (q.categoryId != null) 'categoryId': q.categoryId,
            if (q.destinationId != null) 'destinationId': q.destinationId,
            if (q.yearFrom != null) 'yearFrom': q.yearFrom,
            if (q.yearTo != null) 'yearTo': q.yearTo,
          },
        ),
        cancelToken: token,
      );
      return parsePage(response.data, Tour.fromJson, fallbackSize: q.size);
    });
  }

  @override
  Future<Tour?> findById(int id) => guardRead(() async {
    try {
      final response = await _dio.get<dynamic>('/tours/$id');
      return Tour.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    }
  });

  @override
  Future<bool> codeExists(String code, {int? excludeId}) => guardRead(() async {
    final response = await _dio.get<dynamic>(
      '/tours',
      queryParameters: {'search': code.trim(), 'size': 50, 'page': 1},
    );
    final page = parsePage(response.data, Tour.fromJson);
    final needle = code.trim().toLowerCase();
    return page.items.any(
      (t) => t.code.toLowerCase() == needle && t.id != excludeId,
    );
  });

  @override
  Future<int> countByDestination(int destinationId) => guardRead(
    () => fetchFilteredTotal(_dio, '/tours', {'destinationId': destinationId}),
  );

  @override
  Future<int> countByCategory(int categoryId) => guardRead(
    () => fetchFilteredTotal(_dio, '/tours', {'categoryId': categoryId}),
  );

  @override
  Future<int> countByHotel(int hotelId) =>
      guardRead(() => fetchFilteredTotal(_dio, '/tours', {'hotelId': hotelId}));

  @override
  Future<Tour> create(Tour tour) => guard(() async {
    final response = await _dio.post<dynamic>('/tours', data: _body(tour));
    return Tour.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Tour> update(Tour tour) => guard(() async {
    final response = await _dio.put<dynamic>(
      '/tours/${tour.id}',
      data: _body(tour),
    );
    return Tour.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Tour> book(int id) => guard(() async {
    final response = await _dio.post<dynamic>('/tours/$id/book');
    return Tour.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete<dynamic>('/tours/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete<dynamic>('/tours/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post<dynamic>('/tours/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/tours/bulk-delete',
      data: {'ids': ids},
    );
    return jsonInt((response.data as Map)['deleted']);
  });
}

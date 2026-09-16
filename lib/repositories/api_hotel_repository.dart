import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../data/json_codec.dart';
import '../models/hotel.dart';
import '../models/hotel_query.dart';
import '../models/page_result.dart';
import 'api_tour_repository.dart';
import 'hotel_repository.dart';

class ApiHotelRepository implements HotelRepository {
  ApiHotelRepository(this._dio);
  final Dio _dio;
  CancelToken? _findToken;

  Map<String, dynamic> _body(Hotel hotel) => {
    'name': hotel.name,
    'country': hotel.country,
    'city': hotel.city,
    'stars': hotel.stars,
  };

  @override
  Future<PageResult<Hotel>> find(HotelQuery q) {
    _findToken?.cancel();
    _findToken = CancelToken();
    final token = _findToken!;
    return guardRead(() async {
      final response = await _dio.get<dynamic>(
        '/hotels',
        queryParameters: listQuery(
          search: q.search,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          page: q.page,
          size: q.size,
          includeDeleted: q.includeDeleted,
          extra: {
            if (q.country != null) 'country': q.country,
            if (q.stars != null) 'stars': q.stars,
          },
        ),
        cancelToken: token,
      );
      return parsePage(response.data, Hotel.fromJson, fallbackSize: q.size);
    });
  }

  @override
  Future<List<Hotel>> findAll({bool includeDeleted = false}) => guardRead(
    () => fetchAllRecords(
      _dio,
      '/hotels',
      Hotel.fromJson,
      includeDeleted: includeDeleted,
    ),
  );

  @override
  Future<Hotel?> findById(int id) => guardRead(() async {
    try {
      final response = await _dio.get<dynamic>('/hotels/$id');
      return Hotel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    }
  });

  @override
  Future<Hotel> create(Hotel hotel) => guard(() async {
    final response = await _dio.post<dynamic>('/hotels', data: _body(hotel));
    return Hotel.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Hotel> update(Hotel hotel) => guard(() async {
    final response = await _dio.put<dynamic>(
      '/hotels/${hotel.id}',
      data: _body(hotel),
    );
    return Hotel.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete<dynamic>('/hotels/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete<dynamic>('/hotels/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post<dynamic>('/hotels/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/hotels/bulk-delete',
      data: {'ids': ids},
    );
    return jsonInt((response.data as Map)['deleted']);
  });
}

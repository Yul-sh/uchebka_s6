import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../data/json_codec.dart';
import '../models/catalog_query.dart';
import '../models/lookups.dart';
import '../models/page_result.dart';
import 'api_tour_repository.dart';
import 'lookup_repositories.dart';

class ApiDestinationRepository implements DestinationRepository {
  ApiDestinationRepository(this._dio);
  final Dio _dio;
  CancelToken? _findToken;

  Map<String, dynamic> _body(Destination item) => {
    'name': item.name,
    'country': item.country,
  };

  @override
  Future<PageResult<Destination>> find(CatalogQuery q) {
    _findToken?.cancel();
    _findToken = CancelToken();
    final token = _findToken!;
    return guardRead(() async {
      final response = await _dio.get<dynamic>(
        '/destinations',
        queryParameters: listQuery(
          search: q.search,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          page: q.page,
          size: q.size,
          includeDeleted: q.includeDeleted,
          extra: {if (q.country != null) 'country': q.country},
        ),
        cancelToken: token,
      );
      return parsePage(
        response.data,
        Destination.fromJson,
        fallbackSize: q.size,
      );
    });
  }

  @override
  Future<List<Destination>> findAll({bool includeDeleted = false}) => guardRead(
    () => fetchAllRecords(
      _dio,
      '/destinations',
      Destination.fromJson,
      includeDeleted: includeDeleted,
    ),
  );

  @override
  Future<Destination?> findById(int id) => guardRead(() async {
    try {
      final response = await _dio.get<dynamic>('/destinations/$id');
      return Destination.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    }
  });

  @override
  Future<Destination> create(Destination item) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/destinations',
      data: _body(item),
    );
    return Destination.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Destination> update(Destination item) => guard(() async {
    final response = await _dio.put<dynamic>(
      '/destinations/${item.id}',
      data: _body(item),
    );
    return Destination.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete<dynamic>('/destinations/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete<dynamic>(
      '/destinations/$id',
      queryParameters: {'hard': true},
    ),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post<dynamic>('/destinations/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/destinations/bulk-delete',
      data: {'ids': ids},
    );
    return jsonInt((response.data as Map)['deleted']);
  });
}

class ApiCategoryRepository implements CategoryRepository {
  ApiCategoryRepository(this._dio);
  final Dio _dio;
  CancelToken? _findToken;

  @override
  Future<PageResult<TourCategory>> find(CatalogQuery q) {
    _findToken?.cancel();
    _findToken = CancelToken();
    final token = _findToken!;
    return guardRead(() async {
      final response = await _dio.get<dynamic>(
        '/categories',
        queryParameters: listQuery(
          search: q.search,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          page: q.page,
          size: q.size,
          includeDeleted: q.includeDeleted,
        ),
        cancelToken: token,
      );
      return parsePage(
        response.data,
        TourCategory.fromJson,
        fallbackSize: q.size,
      );
    });
  }

  @override
  Future<List<TourCategory>> findAll({bool includeDeleted = false}) =>
      guardRead(
        () => fetchAllRecords(
          _dio,
          '/categories',
          TourCategory.fromJson,
          includeDeleted: includeDeleted,
        ),
      );

  @override
  Future<TourCategory?> findById(int id) => guardRead(() async {
    try {
      final response = await _dio.get<dynamic>('/categories/$id');
      return TourCategory.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    }
  });

  @override
  Future<TourCategory> create(TourCategory item) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/categories',
      data: {'name': item.name},
    );
    return TourCategory.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<TourCategory> update(TourCategory item) => guard(() async {
    final response = await _dio.put<dynamic>(
      '/categories/${item.id}',
      data: {'name': item.name},
    );
    return TourCategory.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete<dynamic>('/categories/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete<dynamic>(
      '/categories/$id',
      queryParameters: {'hard': true},
    ),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post<dynamic>('/categories/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/categories/bulk-delete',
      data: {'ids': ids},
    );
    return jsonInt((response.data as Map)['deleted']);
  });
}

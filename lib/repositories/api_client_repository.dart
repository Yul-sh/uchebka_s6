import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../data/json_codec.dart';
import '../models/catalog_query.dart';
import '../models/client.dart';
import '../models/page_result.dart';
import 'api_tour_repository.dart';
import 'client_repository.dart';

class ApiClientRepository implements ClientRepository {
  ApiClientRepository(this._dio);
  final Dio _dio;
  CancelToken? _findToken;

  Map<String, dynamic> _body(Client item) => {
    'firstName': item.firstName,
    'lastName': item.lastName,
    'email': item.email,
    'phone': item.phone,
    'card': item.card.toJson(),
  };

  @override
  Future<PageResult<Client>> find(CatalogQuery q) {
    _findToken?.cancel();
    _findToken = CancelToken();
    final token = _findToken!;
    return guardRead(() async {
      final response = await _dio.get<dynamic>(
        '/clients',
        queryParameters: listQuery(
          search: q.search,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          page: q.page,
          size: q.size,
          includeDeleted: q.includeDeleted,
          extra: {if (q.status != null) 'status': q.status},
        ),
        cancelToken: token,
      );
      return parsePage(response.data, Client.fromJson, fallbackSize: q.size);
    });
  }

  @override
  Future<Client?> findById(int id) => guardRead(() async {
    try {
      final response = await _dio.get<dynamic>('/clients/$id');
      return Client.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    }
  });

  @override
  Future<bool> emailExists(String email, {int? excludeId}) =>
      guardRead(() async {
        final response = await _dio.get<dynamic>(
          '/clients',
          queryParameters: {'search': email.trim(), 'size': 50, 'page': 1},
        );
        final page = parsePage(response.data, Client.fromJson);
        final needle = email.trim().toLowerCase();
        return page.items.any(
          (c) => c.email.toLowerCase() == needle && c.id != excludeId,
        );
      });

  @override
  Future<Client> create(Client item) => guard(() async {
    final response = await _dio.post<dynamic>('/clients', data: _body(item));
    return Client.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Client> update(Client item) => guard(() async {
    final response = await _dio.put<dynamic>(
      '/clients/${item.id}',
      data: _body(item),
    );
    return Client.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete<dynamic>('/clients/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete<dynamic>('/clients/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post<dynamic>('/clients/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/clients/bulk-delete',
      data: {'ids': ids},
    );
    return jsonInt((response.data as Map)['deleted']);
  });
}

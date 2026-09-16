import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';

class AdminRepository {
  AdminRepository(this._dio);
  final Dio _dio;

  Future<List<AppUser>> users() => guard(() async {
    final response = await _dio.get<dynamic>('/users');
    final items = (response.data as Map)['items'] as List? ?? [];
    return [
      for (final item in items)
        if (item is Map) AppUser.fromJson(Map<String, dynamic>.from(item)),
    ];
  });

  Future<AppUser> setRole(int id, String role) => guard(() async {
    final response = await _dio.put<dynamic>(
      '/users/$id',
      data: {'role': role},
    );
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  });

  Future<Map<String, int>> stats() => guard(() async {
    final response = await _dio.get<dynamic>('/stats');
    final data = Map<String, dynamic>.from(response.data as Map);
    return {
      for (final entry in data.entries)
        if (entry.value is num) entry.key: (entry.value as num).toInt(),
    };
  });
}

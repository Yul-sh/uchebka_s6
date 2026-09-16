import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Options get _noRefresh => Options(extra: {'skipAuthRefresh': true});

  Future<AuthTokens> login(String username, String password) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/auth/login',
      data: {'username': username, 'password': password},
      options: _noRefresh,
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  });

  Future<AuthTokens> register({
    required String username,
    required String password,
    required String displayName,
  }) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
        'displayName': displayName,
      },
      options: _noRefresh,
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  });

  Future<AppUser> me() => guard(() async {
    final response = await _dio.get<dynamic>('/auth/me', options: _noRefresh);
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  });

  Future<AuthTokens> refresh(String refreshToken) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: _noRefresh,
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  });
}

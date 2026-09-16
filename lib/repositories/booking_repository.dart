import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/booking.dart';

class BookingRepository {
  BookingRepository(this._dio);
  final Dio _dio;

  Future<List<Booking>> all() => guard(() async {
    final response = await _dio.get<dynamic>('/bookings');
    final items = (response.data as Map)['items'] as List? ?? [];
    return [
      for (final item in items)
        if (item is Map) Booking.fromJson(Map<String, dynamic>.from(item)),
    ];
  });

  Future<List<Booking>> mine() => guard(() async {
    final response = await _dio.get<dynamic>('/bookings/mine');
    final items = (response.data as Map)['items'] as List? ?? [];
    return [
      for (final item in items)
        if (item is Map) Booking.fromJson(Map<String, dynamic>.from(item)),
    ];
  });

  Future<Booking> extend(int id, {int days = 7}) => guard(() async {
    final response = await _dio.post<dynamic>(
      '/bookings/$id/extend',
      data: {'days': days},
    );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  });

  Future<Booking> close(int id) => guard(() async {
    final response = await _dio.post<dynamic>('/bookings/$id/close');
    return Booking.fromJson(response.data as Map<String, dynamic>);
  });

  Future<Booking> reopen(int id) => guard(() async {
    final response = await _dio.post<dynamic>('/bookings/$id/reopen');
    return Booking.fromJson(response.data as Map<String, dynamic>);
  });
}

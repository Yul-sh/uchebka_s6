import '../models/hotel.dart';
import '../models/hotel_query.dart';
import '../models/page_result.dart';

abstract interface class HotelRepository {
  Future<PageResult<Hotel>> find(HotelQuery query);
  Future<List<Hotel>> findAll({bool includeDeleted = false});
  Future<Hotel?> findById(int id);
  Future<Hotel> create(Hotel hotel);
  Future<Hotel> update(Hotel hotel);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

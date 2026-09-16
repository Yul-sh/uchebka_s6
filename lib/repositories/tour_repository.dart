import '../models/page_result.dart';
import '../models/tour.dart';
import '../models/tour_query.dart';

abstract interface class TourRepository {
  Future<PageResult<Tour>> find(TourQuery query);
  Future<Tour?> findById(int id);
  Future<bool> codeExists(String code, {int? excludeId});
  Future<int> countByDestination(int destinationId);
  Future<int> countByCategory(int categoryId);
  Future<int> countByHotel(int hotelId);
  Future<Tour> create(Tour tour);
  Future<Tour> update(Tour tour);
  Future<Tour> book(int id);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

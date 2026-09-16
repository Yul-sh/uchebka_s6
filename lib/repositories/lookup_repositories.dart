import '../models/catalog_query.dart';
import '../models/lookups.dart';
import '../models/page_result.dart';

abstract interface class DestinationRepository {
  Future<PageResult<Destination>> find(CatalogQuery query);
  Future<List<Destination>> findAll({bool includeDeleted = false});
  Future<Destination?> findById(int id);
  Future<Destination> create(Destination item);
  Future<Destination> update(Destination item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

abstract interface class CategoryRepository {
  Future<PageResult<TourCategory>> find(CatalogQuery query);
  Future<List<TourCategory>> findAll({bool includeDeleted = false});
  Future<TourCategory?> findById(int id);
  Future<TourCategory> create(TourCategory item);
  Future<TourCategory> update(TourCategory item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

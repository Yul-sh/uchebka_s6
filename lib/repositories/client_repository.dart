import '../models/catalog_query.dart';
import '../models/client.dart';
import '../models/page_result.dart';

abstract interface class ClientRepository {
  Future<PageResult<Client>> find(CatalogQuery query);
  Future<Client?> findById(int id);
  Future<bool> emailExists(String email, {int? excludeId});
  Future<Client> create(Client item);
  Future<Client> update(Client item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

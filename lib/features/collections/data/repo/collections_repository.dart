import '../model/collection.dart';
import '../remote/collections_data_source.dart';

class CollectionsRepository {
  final CollectionsDataSource _dataSource;
  CollectionsRepository(this._dataSource);

  Future<List<Collection>> getCollections() => _dataSource.getCollections();
  Future<void> saveCollection(Collection c) => _dataSource.saveCollection(c);
  Future<void> deleteCollection(String id) => _dataSource.deleteCollection(id);
}

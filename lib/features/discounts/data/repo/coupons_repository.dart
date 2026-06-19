import '../model/coupon.dart';
import '../remote/coupons_data_source.dart';

class CouponsRepository {
  final CouponsDataSource _dataSource;
  CouponsRepository(this._dataSource);

  Future<List<Coupon>> getAll() => _dataSource.getAll();
  Future<void> save(Coupon coupon) => _dataSource.save(coupon);
  Future<void> delete(String id) => _dataSource.delete(id);
  Future<void> setActive(String id, bool active) => _dataSource.setActive(id, active);
}

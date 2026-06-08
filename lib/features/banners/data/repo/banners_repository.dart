import '../model/banner_item.dart';
import '../remote/banners_data_source.dart';

class BannersRepository {
  final BannersDataSource _dataSource;
  BannersRepository(this._dataSource);

  Future<List<BannerItem>> getBanners() => _dataSource.getBanners();
  Future<void> saveBanner(BannerItem b) => _dataSource.saveBanner(b);
  Future<void> deleteBanner(String id) => _dataSource.deleteBanner(id);
}

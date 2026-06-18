import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/remote/auth_data_source.dart';
import '../../features/auth/data/remote/impl/supabase_auth_data_source.dart';
import '../../features/auth/data/repo/auth_repository.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/banners/data/remote/banners_data_source.dart';
import '../../features/banners/data/repo/banners_repository.dart';
import '../../features/banners/presentation/cubits/banners_cubit.dart';
import '../../features/collections/data/remote/collections_data_source.dart';
import '../../features/collections/data/repo/collections_repository.dart';
import '../../features/collections/presentation/cubits/collections_cubit.dart';
import '../../features/orders/data/remote/orders_data_source.dart';
import '../../features/orders/data/repo/orders_repository.dart';
import '../../features/orders/presentation/cubits/orders_cubit.dart';
import '../../features/products/data/remote/impl/supabase_products_data_source.dart';
import '../../features/products/data/remote/products_data_source.dart';
import '../../features/products/data/repo/products_repository.dart';
import '../../features/products/presentation/cubits/products_cubit.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/presentation/settings_cubit.dart';
import '../../features/shipping/data/repo/shipping_repository.dart';
import '../../features/shipping/presentation/cubits/shipping_cubit.dart';
import '../navigation/navigation_cubit.dart';

class DependencyInjector {
  static final DependencyInjector _singleton = DependencyInjector._internal();
  static final Map<Type, dynamic> _deps = {};

  factory DependencyInjector() => _singleton;
  DependencyInjector._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  // Auth
  AuthDataSource get authDataSource =>
      _deps[AuthDataSource] ??= SupabaseAuthDataSource(_supabase);
  AuthRepository get authRepository =>
      _deps[AuthRepository] ??= AuthRepository(authDataSource);
  AuthCubit get authCubit => _deps[AuthCubit] ??= AuthCubit(authRepository);

  // Products
  ProductsDataSource get productsDataSource =>
      _deps[ProductsDataSource] ??= SupabaseProductsDataSource(_supabase);
  ProductsRepository get productsRepository =>
      _deps[ProductsRepository] ??= ProductsRepository(productsDataSource);
  ProductsCubit get productsCubit => ProductsCubit(productsRepository);

  // Collections
  CollectionsDataSource get collectionsDataSource =>
      _deps[CollectionsDataSource] ??= CollectionsDataSource(_supabase);
  CollectionsRepository get collectionsRepository =>
      _deps[CollectionsRepository] ??= CollectionsRepository(collectionsDataSource);
  CollectionsCubit get collectionsCubit => CollectionsCubit(collectionsRepository);

  // Banners
  BannersDataSource get bannersDataSource =>
      _deps[BannersDataSource] ??= BannersDataSource(_supabase);
  BannersRepository get bannersRepository =>
      _deps[BannersRepository] ??= BannersRepository(bannersDataSource);
  BannersCubit get bannersCubit => BannersCubit(bannersRepository);

  // Shipping
  ShippingRepository get shippingRepository =>
      _deps[ShippingRepository] ??= ShippingRepository(_supabase);
  ShippingCubit get shippingCubit => ShippingCubit(shippingRepository);

  // Orders
  OrdersDataSource get ordersDataSource =>
      _deps[OrdersDataSource] ??= OrdersDataSource(_supabase);
  OrdersRepository get ordersRepository =>
      _deps[OrdersRepository] ??= OrdersRepository(ordersDataSource);
  OrdersCubit get ordersCubit => OrdersCubit(ordersRepository);

  // Settings
  SettingsRepository get settingsRepository =>
      _deps[SettingsRepository] ??= SettingsRepository(_supabase);
  SettingsCubit get settingsCubit => SettingsCubit(settingsRepository);

  // Navigation
  NavigationCubit get navigationCubit => _deps[NavigationCubit] ??= NavigationCubit();
}

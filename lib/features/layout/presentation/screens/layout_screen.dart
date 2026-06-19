import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/navigation_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../banners/presentation/screens/banners_mgmt_screen.dart';
import '../../../collections/presentation/screens/collections_mgmt_screen.dart';
import '../../../dashboard_home/presentation/dashboard_home_screen.dart';
import '../../../discounts/presentation/cubits/coupons_cubit.dart';
import '../../../discounts/presentation/screens/discounts_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../products/presentation/screens/products_mgmt_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../shipping/presentation/cubits/shipping_cubit.dart';
import '../../../shipping/presentation/screens/shipping_mgmt_screen.dart';

class LayoutScreen extends StatelessWidget {
  static const String routeName = '/layout';
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.productsCubit..load()),
        BlocProvider(create: (_) => di.collectionsCubit..load()),
        BlocProvider(create: (_) => di.bannersCubit..load()),
        BlocProvider(create: (_) => di.ordersCubit..startRealtime()),
        BlocProvider(create: (_) => di.settingsCubit..load()),
        BlocProvider(create: (_) => di.shippingCubit),
        BlocProvider(create: (_) => di.couponsCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => curr.status == AuthStatus.unauthenticated && prev.status != AuthStatus.unauthenticated,
        listener: (context, _) {
          Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
        },
        child: const _LayoutView(),
      ),
    );
  }
}

class _NavDest {
  const _NavDest(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _LayoutView extends StatelessWidget {
  const _LayoutView();

  static const _kBreakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      DashboardHomeScreen(),
      ProductsMgmtScreen(),
      CollectionsMgmtScreen(),
      BannersMgmtScreen(),
      OrdersScreen(),
      ShippingMgmtScreen(),
      DiscountsScreen(),
      SettingsScreen(),
    ];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, index) {
        final dests = [
          _NavDest(Icons.dashboard_outlined, context.l10n.navDashboard),
          _NavDest(Icons.inventory_2_outlined, context.l10n.navProducts),
          _NavDest(Icons.grid_view_outlined, context.l10n.navCollections),
          _NavDest(Icons.image_outlined, context.l10n.navBanners),
          _NavDest(Icons.receipt_long_outlined, context.l10n.navOrders),
          _NavDest(Icons.local_shipping_outlined, context.l10n.navShipping),
          _NavDest(Icons.local_offer_outlined, context.l10n.navDiscounts),
          _NavDest(Icons.settings_outlined, context.l10n.navSettings),
        ];

        final width = MediaQuery.of(context).size.width;
        final isMobile = width < _kBreakpoint;

        if (isMobile) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: AppBar(
              backgroundColor: AppColors.ink,
              iconTheme: const IconThemeData(color: AppColors.primary),
              title: Image.asset('assets/images/logo.png', height: 40),
              centerTitle: false,
            ),
            drawer: Drawer(
              backgroundColor: AppColors.ink,
              child: SafeArea(
                child: _SideNavContent(dests: dests, index: index, inDrawer: true),
              ),
            ),
            body: screens[index],
          );
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: Row(
            children: [
              _SideNav(dests: dests, index: index),
              Expanded(child: screens[index]),
            ],
          ),
        );
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.dests, required this.index});
  final List<_NavDest> dests;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.ink,
      child: _SideNavContent(dests: dests, index: index),
    );
  }
}

class _SideNavContent extends StatelessWidget {
  const _SideNavContent({required this.dests, required this.index, this.inDrawer = false});
  final List<_NavDest> dests;
  final int index;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!inDrawer)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Image.asset('assets/images/logo.png', height: 56),
          ),
        if (inDrawer) const SizedBox(height: 12),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: dests.length,
            itemBuilder: (context, i) {
              final selected = i == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: Material(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (inDrawer) Navigator.of(context).pop();
                      context.read<NavigationCubit>().navigateTo(i);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(dests[i].icon,
                              size: 20, color: selected ? AppColors.ink : AppColors.primaryLight),
                          const SizedBox(width: 12),
                          Text(
                            dests[i].label,
                            style: AppTextStyles.subtitle.copyWith(
                              color: selected ? AppColors.ink : AppColors.white,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white24, height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, auth) => auth.user != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings_outlined,
                                size: 16, color: AppColors.primaryLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.user!.email,
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              TextButton.icon(
                onPressed: () => context.read<LocaleCubit>().toggle(),
                icon: const Icon(Icons.language, color: AppColors.primaryLight, size: 18),
                label: Text(
                  context.read<LocaleCubit>().isArabic ? context.l10n.english : context.l10n.arabic,
                  style: AppTextStyles.label.copyWith(color: AppColors.white),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: Text(context.l10n.logout,
                    style: AppTextStyles.label.copyWith(color: AppColors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

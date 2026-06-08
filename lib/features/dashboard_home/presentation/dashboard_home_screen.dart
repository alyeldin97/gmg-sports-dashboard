import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/price_x.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/styling/colors.dart';
import '../../../core/styling/text_styles.dart';
import '../../orders/data/model/order.dart';
import '../../orders/presentation/cubits/orders_cubit.dart';
import '../../products/presentation/cubits/products_cubit.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.overview, style: AppTextStyles.heading1),
          const SizedBox(height: 20),
          BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, orders) {
              return BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, products) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard(
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.accentBlue,
                        label: context.l10n.totalOrders,
                        value: '${orders.orders.length}',
                      ),
                      _StatCard(
                        icon: Icons.schedule_rounded,
                        color: AppColors.accentOrange,
                        label: context.l10n.pendingOrders,
                        value: '${orders.pendingCount}',
                      ),
                      _StatCard(
                        icon: Icons.payments_rounded,
                        color: AppColors.accentGreen,
                        label: context.l10n.revenue,
                        value: '${orders.revenue.asPrice} ${context.l10n.currency}',
                      ),
                      _StatCard(
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.primaryDark,
                        label: context.l10n.totalProducts,
                        value: '${products.products.length}',
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),
          Text(context.l10n.recentOrders, style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              final recent = state.orders.take(8).toList();
              if (recent.isEmpty) {
                return Text(context.l10n.noOrders, style: AppTextStyles.bodySmall);
              }
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (final o in recent) _RecentRow(order: o),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.heading2, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('#${order.shortId}', style: AppTextStyles.subtitle),
          const SizedBox(width: 16),
          Text(order.recipientName, style: AppTextStyles.body),
          const Spacer(),
          Text(DateFormat('d MMM').format(order.createdAt), style: AppTextStyles.bodySmall),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: order.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(order.status.localizedLabel(context),
                style: AppTextStyles.bodySmall.copyWith(color: order.status.color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
          Text('${order.total.asPrice} ${context.l10n.currency}', style: AppTextStyles.price),
        ],
      ),
    );
  }
}

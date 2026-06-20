import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/price_x.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/navigation/navigation_cubit.dart';
import '../../../core/styling/colors.dart';
import '../../../core/styling/text_styles.dart';
import '../../orders/data/model/order.dart';
import '../../products/data/model/product.dart';
import '../../products/presentation/cubits/products_cubit.dart';
import '../../products/presentation/screens/product_form_screen.dart';
import 'cubits/dashboard_stats_cubit.dart';

const int _kDiscountsNavIndex = 6;
const int _kLowStockThreshold = 5;

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with quick actions ──
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 620;
              final title = Text(context.l10n.overview, style: AppTextStyles.heading1);
              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _QuickActionButton(
                    icon: Icons.add_rounded,
                    label: context.l10n.addProduct,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProductsCubit>(),
                          child: const ProductFormScreen(),
                        ),
                      ),
                    ),
                  ),
                  _QuickActionButton(
                    icon: Icons.local_offer_outlined,
                    label: context.l10n.addCoupon,
                    filled: false,
                    onTap: () =>
                        context.read<NavigationCubit>().navigateTo(_kDiscountsNavIndex),
                  ),
                ],
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 14), actions],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [title, const Spacer(), actions],
              );
            },
          ),
          const SizedBox(height: 24),

          // ── Summary stats ──
          BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
            builder: (context, stats) {
              return BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, products) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard(
                        icon: Icons.payments_rounded,
                        color: AppColors.accentGreen,
                        label: context.l10n.monthRevenue,
                        value: '${stats.monthRevenue.asPrice} ${context.l10n.currency}',
                      ),
                      _StatCard(
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.accentBlue,
                        label: context.l10n.totalOrders,
                        value: '${stats.totalOrders}',
                      ),
                      _StatCard(
                        icon: Icons.schedule_rounded,
                        color: AppColors.accentOrange,
                        label: context.l10n.pendingOrders,
                        value: '${stats.pendingOrders}',
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

          // ── Charts row ──
          LayoutBuilder(
            builder: (context, c) {
              final stacked = c.maxWidth < 900;
              final trend = _Panel(
                title: context.l10n.salesTrend,
                child: const SizedBox(height: 220, child: _SalesTrendChart()),
              );
              final byStatus = _Panel(
                title: context.l10n.ordersByStatus,
                child: const SizedBox(height: 220, child: _OrdersByStatusChart()),
              );
              if (stacked) {
                return Column(
                  children: [trend, const SizedBox(height: 16), byStatus],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: trend),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: byStatus),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Latest orders ──
          Row(
            children: [
              Text(context.l10n.recentOrders, style: AppTextStyles.heading2),
              const Spacer(),
              TextButton(
                onPressed: () => context.read<NavigationCubit>().navigateTo(4),
                child: Text(context.l10n.viewAll, style: AppTextStyles.label),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _LatestOrdersTable(),
          const SizedBox(height: 28),

          // ── Low stock + Top products ──
          LayoutBuilder(
            builder: (context, c) {
              final stacked = c.maxWidth < 900;
              final lowStock = _Panel(
                title: context.l10n.lowStockAlert,
                child: const _LowStockList(),
              );
              final topProducts = _Panel(
                title: context.l10n.topProducts,
                child: const _TopProductsList(),
              );
              if (stacked) {
                return Column(
                  children: [lowStock, const SizedBox(height: 16), topProducts],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: lowStock),
                  const SizedBox(width: 16),
                  Expanded(child: topProducts),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = true,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.ink),
        label: Text(label, style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.ink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.ink),
      label: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.ink)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          child,
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

// ─── Sales trend line chart ───────────────────────────────────────────────────

class _SalesTrendChart extends StatelessWidget {
  const _SalesTrendChart();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
      builder: (context, stats) {
        if (stats.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
        }
        final data = stats.revenueByDay;
        if (data.isEmpty) {
          return Center(child: Text(context.l10n.noData, style: AppTextStyles.bodySmall));
        }
        final spots = <FlSpot>[
          for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value),
        ];
        final maxY = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);
        final interval = maxY <= 0 ? 1.0 : maxY / 4;

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: maxY <= 0 ? 10 : maxY * 1.2,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval <= 0 ? 1 : interval,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: interval <= 0 ? 1 : interval,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max) return const SizedBox.shrink();
                    return Text(
                      value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('E').format(data[i].key),
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primaryDark,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Orders by status donut chart ─────────────────────────────────────────────

class _OrdersByStatusChart extends StatelessWidget {
  const _OrdersByStatusChart();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
      builder: (context, stats) {
        if (stats.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
        }
        final entries = OrderStatus.values
            .map((s) => MapEntry(s, stats.ordersByStatus[s.name] ?? 0))
            .where((e) => e.value > 0)
            .toList();
        final total = entries.fold<int>(0, (sum, e) => sum + e.value);
        if (total == 0) {
          return Center(child: Text(context.l10n.noData, style: AppTextStyles.bodySmall));
        }
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 38,
                  sections: [
                    for (final e in entries)
                      PieChartSectionData(
                        value: e.value.toDouble(),
                        color: e.key.color,
                        title: '${e.value}',
                        radius: 46,
                        titleStyle: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key.localizedLabel(context),
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('${e.value}',
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Latest orders table ──────────────────────────────────────────────────────

class _LatestOrdersTable extends StatelessWidget {
  const _LatestOrdersTable();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
      builder: (context, stats) {
        final recent = stats.recentOrders;
        if (stats.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
          );
        }
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
          SizedBox(width: 90, child: Text('#${order.shortId}', style: AppTextStyles.subtitle)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(order.recipientName,
                style: AppTextStyles.body, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 12),
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
          SizedBox(
            width: 110,
            child: Text('${order.total.asPrice} ${context.l10n.currency}',
                style: AppTextStyles.price, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

// ─── Low stock list ───────────────────────────────────────────────────────────

class _LowStockList extends StatelessWidget {
  const _LowStockList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final low = state.products.where((p) => p.stock <= _kLowStockThreshold).toList()
          ..sort((a, b) => a.stock.compareTo(b.stock));
        if (low.isEmpty) {
          return Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.accentGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(context.l10n.noLowStock, style: AppTextStyles.bodySmall)),
            ],
          );
        }
        return Column(
          children: [
            for (final p in low.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p.name,
                            style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.stockLeft(p.stock),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Top products (by order count) ────────────────────────────────────────────

class _TopProductsList extends StatelessWidget {
  const _TopProductsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
      builder: (context, stats) {
        return BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, productsState) {
            // Count quantity sold per product name across all (non-cancelled) orders.
            final counts = <String, int>{};
            for (final o in stats.recentOrders) {
              if (o.status == OrderStatus.cancelled) continue;
              for (final item in o.items) {
                counts[item.name] = (counts[item.name] ?? 0) + item.quantity;
              }
            }
            // Fold in deeper data is limited to recentOrders here; supplement names
            // from the products list so we always have something to show.
            final ranked = counts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final top = ranked.take(5).toList();

            if (top.isEmpty) {
              // Fallback: show featured / first products if no order item data.
              final fallback = productsState.products.take(5).toList();
              if (fallback.isEmpty) {
                return Text(context.l10n.noData, style: AppTextStyles.bodySmall);
              }
              return Column(
                children: [for (final p in fallback) _TopRow(name: p.name, trailing: null, product: p)],
              );
            }

            Product? findProduct(String name) {
              for (final p in productsState.products) {
                if (p.name == name) return p;
              }
              return null;
            }

            return Column(
              children: [
                for (var i = 0; i < top.length; i++)
                  _TopRow(
                    rank: i + 1,
                    name: top[i].key,
                    trailing: '${top[i].value}',
                    product: findProduct(top[i].key),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({this.rank, required this.name, required this.trailing, this.product});
  final int? rank;
  final String name;
  final String? trailing;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (rank != null) ...[
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryMist,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('$rank',
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(name, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textMid),
            const SizedBox(width: 4),
            Text(trailing!,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

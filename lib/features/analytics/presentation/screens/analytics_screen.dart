import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/price_x.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../orders/data/model/order.dart';
import '../cubits/analytics_cubit.dart';

enum _Preset { today, yesterday, last7, thisMonth, custom }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  _Preset _preset = _Preset.today;

  Future<void> _select(_Preset preset) async {
    final cubit = context.read<AnalyticsCubit>();
    switch (preset) {
      case _Preset.today:
        await cubit.loadForToday();
        break;
      case _Preset.yesterday:
        await cubit.loadForYesterday();
        break;
      case _Preset.last7:
        await cubit.loadForLast7Days();
        break;
      case _Preset.thisMonth:
        await cubit.loadForThisMonth();
        break;
      case _Preset.custom:
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(now.year, now.month, now.day),
          helpText: context.l10n.selectDateRange,
        );
        if (picked == null) return;
        final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
        // End is exclusive: include the whole end day.
        final end = DateTime(picked.end.year, picked.end.month, picked.end.day)
            .add(const Duration(days: 1));
        await cubit.setRange(start, end);
        break;
    }
    if (mounted) setState(() => _preset = preset);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.analyticsTitle, style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          _PresetChips(selected: _preset, onSelect: _select),
          const SizedBox(height: 24),
          BlocBuilder<AnalyticsCubit, AnalyticsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
                );
              }
              if (state.error != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.somethingWrong, style: AppTextStyles.body),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<AnalyticsCubit>().load(),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricCards(state: state),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, c) {
                      final stacked = c.maxWidth < 900;
                      final trend = _Panel(
                        title: context.l10n.revenueTrend,
                        child: SizedBox(height: 240, child: _RevenueChart(state: state)),
                      );
                      final status = _Panel(
                        title: context.l10n.ordersByStatus,
                        child: SizedBox(height: 240, child: _StatusChart(state: state)),
                      );
                      if (stacked) {
                        return Column(children: [trend, const SizedBox(height: 16), status]);
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: trend),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: status),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _Panel(
                    title: context.l10n.topProducts,
                    child: _TopProductsTable(state: state),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PresetChips extends StatelessWidget {
  const _PresetChips({required this.selected, required this.onSelect});
  final _Preset selected;
  final ValueChanged<_Preset> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(_Preset, String)>[
      (_Preset.today, context.l10n.today),
      (_Preset.yesterday, context.l10n.yesterday),
      (_Preset.last7, context.l10n.last7Days),
      (_Preset.thisMonth, context.l10n.thisMonth),
      (_Preset.custom, context.l10n.customRange),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (preset, label) in items)
          ChoiceChip(
            label: Text(label),
            selected: selected == preset,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            labelStyle: AppTextStyles.label.copyWith(
              color: selected == preset ? AppColors.ink : AppColors.textMid,
              fontWeight: selected == preset ? FontWeight.w800 : FontWeight.w600,
            ),
            onSelected: (_) => onSelect(preset),
          ),
      ],
    );
  }
}

class _MetricCards extends StatelessWidget {
  const _MetricCards({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _MetricCard(
          icon: Icons.payments_rounded,
          color: AppColors.accentGreen,
          label: context.l10n.totalRevenue,
          value: '${state.totalRevenue.asPrice} ${context.l10n.currency}',
          change: state.revenueChange,
        ),
        _MetricCard(
          icon: Icons.receipt_long_rounded,
          color: AppColors.accentBlue,
          label: context.l10n.totalOrders,
          value: '${state.totalOrders}',
          change: state.ordersChange,
        ),
        _MetricCard(
          icon: Icons.shopping_bag_rounded,
          color: AppColors.accentOrange,
          label: context.l10n.avgOrderValue,
          value: '${state.avgOrderValue.asPrice} ${context.l10n.currency}',
          change: state.avgOrderChange,
        ),
        _MetricCard(
          icon: Icons.people_alt_rounded,
          color: AppColors.primaryDark,
          label: context.l10n.uniqueCustomers,
          value: '${state.newCustomers}',
          change: null,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.change,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final double? change;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              if (change != null) _ChangeBadge(change: change!),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: AppTextStyles.heading2, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.change});
  final double change;

  @override
  Widget build(BuildContext context) {
    final positive = change >= 0;
    final color = positive ? AppColors.accentGreen : AppColors.error;
    return Tooltip(
      message: context.l10n.vsLastPeriod,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12, color: color),
            const SizedBox(width: 2),
            Text('${change.abs().toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
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

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final data = state.revenueByDay;
    final hasRevenue = data.any((e) => e.value > 0);
    if (data.isEmpty || !hasRevenue) {
      return Center(child: Text(context.l10n.noAnalyticsData, style: AppTextStyles.bodySmall));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value),
    ];
    final maxY = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final interval = maxY <= 0 ? 1.0 : maxY / 4;
    // Avoid clutter on long ranges.
    final labelEvery = (data.length / 7).ceil().clamp(1, data.length);

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
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
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
                if (i % labelEvery != 0 && i != data.length - 1) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('d/M').format(data[i].key),
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
            dotData: FlDotData(show: data.length <= 14),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.18)),
          ),
        ],
      ),
    );
  }
}

class _StatusChart extends StatelessWidget {
  const _StatusChart({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final entries = OrderStatus.values
        .map((s) => MapEntry(s, state.ordersByStatus[s.name] ?? 0))
        .where((e) => e.value > 0)
        .toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total == 0) {
      return Center(child: Text(context.l10n.noAnalyticsData, style: AppTextStyles.bodySmall));
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
                        child: Text(e.key.localizedLabel(context),
                            style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
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
  }
}

class _TopProductsTable extends StatelessWidget {
  const _TopProductsTable({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final products = state.topProducts;
    if (products.isEmpty) {
      return Text(context.l10n.noAnalyticsData, style: AppTextStyles.bodySmall);
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Expanded(flex: 4, child: Text(context.l10n.name, style: AppTextStyles.label)),
              Expanded(flex: 2, child: Text(context.l10n.unitsSold, style: AppTextStyles.label, textAlign: TextAlign.end)),
              Expanded(flex: 3, child: Text(context.l10n.totalRevenue, style: AppTextStyles.label, textAlign: TextAlign.end)),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        for (var i = 0; i < products.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMist,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${i + 1}',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(products[i].name,
                      style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  flex: 2,
                  child: Text('${products[i].units}',
                      style: AppTextStyles.body, textAlign: TextAlign.end),
                ),
                Expanded(
                  flex: 3,
                  child: Text('${products[i].revenue.asPrice} ${context.l10n.currency}',
                      style: AppTextStyles.price, textAlign: TextAlign.end),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

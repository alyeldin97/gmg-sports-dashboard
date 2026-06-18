// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/model/order.dart';
import '../cubits/orders_cubit.dart';
import 'order_details_screen.dart';

enum _SortMode { newest, oldest }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _SortMode _sort = _SortMode.newest;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _exportCsv(List<Order> orders) {
    final buf = StringBuffer();
    buf.writeln('Order ID,Recipient,Phone,Address,Date,Delivery Date,Status,Payment,Subtotal,Shipping,Total,Notes');
    for (final o in orders) {
      final row = [
        o.shortId,
        o.recipientName,
        o.recipientPhone,
        '"${o.addressText.replaceAll('"', '""')}"',
        DateFormat('yyyy-MM-dd').format(o.createdAt),
        o.deliveryDate != null ? DateFormat('yyyy-MM-dd').format(o.deliveryDate!) : '',
        o.status.dbValue,
        o.isCod ? 'COD' : 'InstaPay',
        o.subtotal.toStringAsFixed(2),
        o.deliveryFee.toStringAsFixed(2),
        o.total.toStringAsFixed(2),
        '"${(o.notes ?? '').replaceAll('"', '""')}"',
      ];
      buf.writeln(row.join(','));
    }
    final blob = html.Blob([buf.toString()], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'orders_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  List<Order> _filter(List<Order> orders) {
    final q = _query.toLowerCase();
    var result = q.isEmpty
        ? orders
        : orders.where((o) =>
            o.shortId.toLowerCase().contains(q) ||
            o.recipientName.toLowerCase().contains(q) ||
            o.recipientPhone.contains(q)).toList();
    result = [...result];
    result.sort((a, b) => _sort == _SortMode.newest
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.customerOrders, style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: context.l10n.search,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<_SortMode>(
                value: _sort,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(value: _SortMode.newest, child: Text(context.l10n.newestFirst)),
                  DropdownMenuItem(value: _SortMode.oldest, child: Text(context.l10n.oldestFirst)),
                ],
                onChanged: (v) => setState(() => _sort = v ?? _SortMode.newest),
              ),
              const SizedBox(width: 12),
              BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) => OutlinedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(context.l10n.exportCsv),
                  onPressed: state.orders.isEmpty
                      ? null
                      : () => _exportCsv(_filter(state.orders)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                if ((state.status == OrdersStatus.loading || state.status == OrdersStatus.initial) && state.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.status == OrdersStatus.failure && state.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.somethingWrong, style: AppTextStyles.body),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<OrdersCubit>().load(),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  );
                }
                final filtered = _filter(state.orders);
                if (filtered.isEmpty) {
                  return EmptyState(icon: Icons.receipt_long_outlined, title: context.l10n.noOrders);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, i) => _OrderRow(order: filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final cubit = context.read<OrdersCubit>();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider.value(value: cubit, child: OrderDetailsScreen(orderId: order.id)),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text('#${order.shortId}', style: AppTextStyles.subtitle)),
            Expanded(flex: 2, child: Text(order.recipientName, style: AppTextStyles.body)),
            Expanded(flex: 2, child: Text(order.recipientPhone, style: AppTextStyles.bodySmall)),
            Expanded(child: Text(DateFormat('d MMM').format(order.createdAt), style: AppTextStyles.bodySmall)),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  Icon(
                    order.isCod ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      order.isCod ? context.l10n.cod : 'InstaPay',
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                  textAlign: TextAlign.end, style: AppTextStyles.price),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

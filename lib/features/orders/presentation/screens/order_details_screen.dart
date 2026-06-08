import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../data/model/order.dart';
import '../cubits/orders_cubit.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});
  final String orderId;

  Order? _find(OrdersState state) {
    final match = state.orders.where((o) => o.id == orderId);
    return match.isEmpty ? null : match.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(context.l10n.orderDetails, style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final order = _find(state);
          if (order == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _Card(
                    child: Row(
                      children: [
                        Text(context.l10n.orderNumber(order.shortId), style: AppTextStyles.heading3),
                        const Spacer(),
                        _StatusDropdown(order: order),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.recipient, style: AppTextStyles.subtitle),
                        const SizedBox(height: 4),
                        Text('${order.recipientName} · ${order.recipientPhone}', style: AppTextStyles.body),
                        const SizedBox(height: 10),
                        Text(context.l10n.deliveryAddress, style: AppTextStyles.subtitle),
                        const SizedBox(height: 4),
                        Text(order.addressText, style: AppTextStyles.body),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _kv(context, context.l10n.paymentMethod,
                                  order.isCod ? context.l10n.cod : context.l10n.instapay),
                            ),
                            if (order.deliveryDate != null)
                              Expanded(
                                child: _kv(context, context.l10n.deliveryDate,
                                    DateFormat('EEE, d MMM yyyy').format(order.deliveryDate!)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Column(
                      children: [
                        for (final item in order.items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Text('${item.quantity}×', style: AppTextStyles.label),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.variantName != null ? '${item.name} (${item.variantName})' : item.name,
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                Text('${item.subtotal.asPrice} ${context.l10n.currency}', style: AppTextStyles.label),
                              ],
                            ),
                          ),
                        const Divider(color: AppColors.border),
                        _kvRow(context, context.l10n.subtotal, order.subtotal),
                        _kvRow(context, context.l10n.deliveryFee, order.deliveryFee),
                        const SizedBox(height: 4),
                        _kvRow(context, context.l10n.total, order.total, bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: AppTextStyles.label),
          Text(v, style: AppTextStyles.body),
        ],
      );

  Widget _kvRow(BuildContext context, String k, double v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: bold ? AppTextStyles.subtitle : AppTextStyles.label),
            Text('${v.asPrice} ${context.l10n.currency}', style: bold ? AppTextStyles.price : AppTextStyles.body),
          ],
        ),
      );
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: order.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          value: order.status,
          borderRadius: BorderRadius.circular(10),
          items: OrderStatus.values
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.localizedLabel(context),
                        style: AppTextStyles.label.copyWith(color: s.color, fontWeight: FontWeight.w700)),
                  ))
              .toList(),
          onChanged: (s) {
            if (s != null && s != order.status) {
              context.read<OrdersCubit>().updateStatus(order, s);
            }
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

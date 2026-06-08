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

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.customerOrders, style: AppTextStyles.heading1),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                if (state.status == OrdersStatus.loading || state.status == OrdersStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.orders.isEmpty) {
                  return EmptyState(icon: Icons.receipt_long_outlined, title: context.l10n.noOrders);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, i) => _OrderRow(order: state.orders[i]),
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

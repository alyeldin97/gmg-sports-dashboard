// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../data/model/order.dart';
import '../cubits/orders_cubit.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final order = await context.read<OrdersCubit>().getOrderById(widget.orderId);
      if (mounted) setState(() { _order = order; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _printInvoice() {
    final order = _order;
    if (order == null) return;
    final html = _buildInvoiceHtml(order);
    js.context['_gmgInvoiceHtml'] = html;
    js.context.callMethod('eval', [r'''
      (function() {
        var w = window.open('', '_blank', 'width=900,height=700');
        w.document.write(window._gmgInvoiceHtml);
        w.document.close();
        w.focus();
        setTimeout(function() { w.print(); }, 600);
      })();
    ''']);
  }

  String _buildInvoiceHtml(Order order) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt.toLocal());
    final deliveryStr = order.deliveryDate != null
        ? DateFormat('dd/MM/yyyy').format(order.deliveryDate!)
        : '';

    final itemsHtml = order.items.map((item) {
      final name = item.variantName != null
          ? '${item.name} (${item.variantName})'
          : item.name;
      return '''<tr>
        <td>$name</td>
        <td style="text-align:center">${item.quantity}</td>
        <td style="text-align:right">${item.unitPrice.toStringAsFixed(2)} EGP</td>
        <td style="text-align:right">${item.subtotal.toStringAsFixed(2)} EGP</td>
      </tr>''';
    }).join('');

    final discountRow = order.discount > 0
        ? '<tr><td colspan="2">Discount</td><td style="text-align:right">-${order.discount.toStringAsFixed(2)} EGP</td></tr>'
        : '';

    final notesSection = (order.notes != null && order.notes!.isNotEmpty)
        ? '<div style="margin-top:24px;padding:12px;background:#f9f9f9;border-radius:6px"><strong>Notes:</strong> ${order.notes}</div>'
        : '';

    final emailLine = (order.guestEmail != null && order.guestEmail!.isNotEmpty)
        ? '${order.guestEmail}<br>'
        : '';

    final deliveryLine = deliveryStr.isNotEmpty
        ? 'Delivery: <strong>$deliveryStr</strong><br>'
        : '';

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice #${order.shortId}</title>
  <style>
    * { margin:0;padding:0;box-sizing:border-box; }
    body { font-family:Arial,sans-serif;font-size:14px;color:#1a1a1a;padding:40px; }
    .header { display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:32px;padding-bottom:24px;border-bottom:2px solid #1a1a1a; }
    .brand { font-size:26px;font-weight:700; }
    .brand-sub { font-size:12px;color:#666;margin-top:3px; }
    .inv-title { text-align:right; }
    .inv-title h2 { font-size:30px;font-weight:300;letter-spacing:5px;color:#1a1a1a; }
    .inv-title p { font-size:13px;color:#666;margin-top:4px; }
    .info-grid { display:grid;grid-template-columns:1fr 1fr;gap:24px;margin-bottom:32px; }
    .info-block h4 { font-size:10px;text-transform:uppercase;letter-spacing:1.5px;color:#999;margin-bottom:8px;font-weight:600; }
    .info-block p { font-size:13px;line-height:1.7; }
    table { width:100%;border-collapse:collapse;margin-bottom:0; }
    thead tr { background:#f5f5f5; }
    thead th { padding:10px 14px;text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:1px;color:#666;font-weight:600; }
    tbody tr { border-bottom:1px solid #f0f0f0; }
    tbody td { padding:10px 14px;font-size:13px; }
    .totals-wrap { display:flex;justify-content:flex-end;margin-top:8px; }
    .totals-table { width:300px;border-collapse:collapse; }
    .totals-table td { padding:5px 14px;font-size:13px; }
    .totals-table .grand td { font-weight:700;font-size:16px;border-top:2px solid #1a1a1a;padding-top:10px; }
    .footer { margin-top:48px;padding-top:20px;border-top:1px solid #eee;text-align:center;font-size:11px;color:#aaa; }
    @media print { body{padding:15px} @page{margin:10mm} }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <div class="brand">GMG Sports</div>
      <div class="brand-sub">Sports &amp; Athletic Gear</div>
    </div>
    <div class="inv-title">
      <h2>INVOICE</h2>
      <p>#${order.shortId}</p>
      <p>$dateStr</p>
    </div>
  </div>

  <div class="info-grid">
    <div class="info-block">
      <h4>Bill To</h4>
      <p>
        <strong>${order.recipientName}</strong><br>
        ${order.recipientPhone}<br>
        $emailLine
        ${order.addressText}
      </p>
    </div>
    <div class="info-block">
      <h4>Order Details</h4>
      <p>
        Status: <strong>${order.status.dbValue.replaceAll('_', ' ').toUpperCase()}</strong><br>
        Payment: <strong>${order.isCod ? 'Cash on Delivery' : 'InstaPay'}</strong><br>
        $deliveryLine
      </p>
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th>Product</th>
        <th style="text-align:center">Qty</th>
        <th style="text-align:right">Unit Price</th>
        <th style="text-align:right">Subtotal</th>
      </tr>
    </thead>
    <tbody>
      $itemsHtml
    </tbody>
  </table>

  <div class="totals-wrap">
    <table class="totals-table">
      <tr><td>Subtotal</td><td style="text-align:right">${order.subtotal.toStringAsFixed(2)} EGP</td></tr>
      <tr><td>Delivery Fee</td><td style="text-align:right">${order.deliveryFee.toStringAsFixed(2)} EGP</td></tr>
      $discountRow
      <tr class="grand"><td>Total</td><td style="text-align:right">${order.total.toStringAsFixed(2)} EGP</td></tr>
    </table>
  </div>

  $notesSection

  <div class="footer">
    <p>Thank you for shopping with GMG Sports!</p>
  </div>
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(context.l10n.orderDetails, style: AppTextStyles.heading3),
        actions: [
          if (_order != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: _printInvoice,
                icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.primaryDark),
                label: Text('Print Invoice',
                    style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
              ),
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
    if (_error != null) return Center(child: Text(_error!, style: AppTextStyles.body));
    final order = _order;
    if (order == null) return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));

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
                  _StatusDropdown(order: order, onRefresh: _fetch),
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
                  if (order.guestEmail != null && order.guestEmail!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(order.guestEmail!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
                  ],
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
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(context.l10n.orderNotes, style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(order.notes!, style: AppTextStyles.body),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                children: [
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.imageUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                                  )
                                : _imagePlaceholder(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: AppTextStyles.body),
                                if (item.variantName != null)
                                  Text(item.variantName!,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${item.quantity}×',
                              style: AppTextStyles.label.copyWith(color: AppColors.textLight)),
                          const SizedBox(width: 12),
                          Text('${item.subtotal.asPrice} ${context.l10n.currency}',
                              style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  const Divider(color: AppColors.border),
                  _kvRow(context, context.l10n.subtotal, order.subtotal),
                  _kvRow(context, context.l10n.deliveryFee, order.deliveryFee),
                  if (order.discount > 0)
                    _kvRow(context, context.l10n.discount, -order.discount),
                  const SizedBox(height: 4),
                  _kvRow(context, context.l10n.total, order.total, bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.image_outlined, size: 22, color: AppColors.border),
      );

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
            Text('${v.asPrice} ${context.l10n.currency}',
                style: bold ? AppTextStyles.price : AppTextStyles.body),
          ],
        ),
      );
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.order, required this.onRefresh});
  final Order order;
  final VoidCallback onRefresh;

  void _confirmChange(BuildContext context, OrderStatus newStatus) {
    final cubit = context.read<OrdersCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.updateStatus),
        content: Text('${context.l10n.updateStatus}: "${newStatus.localizedLabel(context)}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await cubit.updateStatus(order, newStatus);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      ok ? context.l10n.statusUpdated : context.l10n.failedToUpdateStatus),
                ));
                if (ok) onRefresh();
              }
            },
            child: Text(context.l10n.confirmStr),
          ),
        ],
      ),
    );
  }

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
                        style: AppTextStyles.label
                            .copyWith(color: s.color, fontWeight: FontWeight.w700)),
                  ))
              .toList(),
          onChanged: (s) {
            if (s != null && s != order.status) _confirmChange(context, s);
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

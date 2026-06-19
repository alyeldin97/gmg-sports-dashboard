import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../settings/data/app_settings.dart';
import '../../../settings/presentation/settings_cubit.dart';
import '../../data/model/coupon.dart';
import '../cubits/coupons_cubit.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CouponsCubit>().load();
  }

  void _openForm([Coupon? coupon]) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CouponsCubit>(),
        child: _CouponFormDialog(coupon: coupon),
      ),
    );
  }

  Future<void> _confirmDelete(Coupon c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text('${context.l10n.deleteMessage} "${c.code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final success = await context.read<CouponsCubit>().delete(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? context.l10n.couponDeleted : context.l10n.somethingWrong),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.discountsTitle, style: AppTextStyles.heading1),
              AppButton(
                label: '+ ${context.l10n.newCoupon}',
                onPressed: () => _openForm(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Free Shipping Rule ──────────────────────────────────────────
          const _FreeShippingCard(),
          const SizedBox(height: 20),
          // ── Coupon Codes ───────────────────────────────────────────────
          Text(context.l10n.couponCodes, style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<CouponsCubit, CouponsState>(
              builder: (context, state) {
                if (state.status == CouponsStatus.loading && state.coupons.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.coupons.isEmpty) {
                  return Center(child: Text(context.l10n.noCoupons, style: AppTextStyles.label));
                }
                return _CouponsTable(
                  coupons: state.coupons,
                  onEdit: _openForm,
                  onDelete: _confirmDelete,
                  onToggle: (c) => context.read<CouponsCubit>().toggleActive(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Free Shipping Card ───────────────────────────────────────────────────────

class _FreeShippingCard extends StatefulWidget {
  const _FreeShippingCard();

  @override
  State<_FreeShippingCard> createState() => _FreeShippingCardState();
}

class _FreeShippingCardState extends State<_FreeShippingCard> {
  final _ctrl = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _startEdit(double current) {
    _ctrl.text = current.toStringAsFixed(0);
    setState(() => _editing = true);
  }

  Future<void> _save(AppSettings settings) async {
    final v = double.tryParse(_ctrl.text.trim());
    if (v == null || v < 0) return;
    setState(() => _saving = true);
    await context.read<SettingsCubit>().save(settings.copyWith(freeDeliveryThreshold: v));
    if (mounted) setState(() { _editing = false; _saving = false; });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final threshold = state.settings.freeDeliveryThreshold;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryMist,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _editing
                    ? Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: context.l10n.freeShippingThreshold,
                              controller: _ctrl,
                              keyboardType: TextInputType.number,
                              validator: AppValidator.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppButton(
                            label: context.l10n.save,
                            loading: _saving,
                            onPressed: () => _save(state.settings),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _editing = false),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.freeShippingRule, style: AppTextStyles.label),
                          const SizedBox(height: 2),
                          Text(
                            threshold > 0
                                ? context.l10n.freeShippingThresholdValue(threshold.toStringAsFixed(0))
                                : context.l10n.disabled,
                            style: AppTextStyles.body.copyWith(
                              color: threshold > 0 ? AppColors.accentGreen : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
              ),
              if (!_editing)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textLight),
                  onPressed: () => _startEdit(threshold),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CouponsTable extends StatelessWidget {
  const _CouponsTable({
    required this.coupons,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });
  final List<Coupon> coupons;
  final ValueChanged<Coupon> onEdit;
  final ValueChanged<Coupon> onDelete;
  final ValueChanged<Coupon> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.scaffoldBg),
              columns: [
                DataColumn(label: Text(context.l10n.couponCodeLabel, style: AppTextStyles.label)),
                DataColumn(label: Text(context.l10n.discountType, style: AppTextStyles.label)),
                DataColumn(label: Text(context.l10n.discountValueLabel, style: AppTextStyles.label)),
                DataColumn(label: Text(context.l10n.minOrderAmountLabel, style: AppTextStyles.label)),
                DataColumn(label: Text(context.l10n.usedCount, style: AppTextStyles.label)),
                DataColumn(label: Text(context.l10n.expiryDateLabel, style: AppTextStyles.label)),
                DataColumn(label: Text(context.l10n.active, style: AppTextStyles.label)),
                const DataColumn(label: Text('')),
              ],
              rows: coupons.map((c) {
                final expired = c.isExpired;
                return DataRow(cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.code,
                            style: AppTextStyles.label.copyWith(
                              fontFamily: 'monospace',
                              color: expired ? AppColors.textLight : AppColors.ink,
                            )),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: c.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1)),
                            );
                          },
                          child: const Icon(Icons.copy_outlined, size: 14, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(
                    c.isPercentage ? context.l10n.percentageType : context.l10n.fixedType,
                    style: AppTextStyles.body,
                  )),
                  DataCell(Text(
                    c.isPercentage ? '${c.discountValue.toStringAsFixed(0)}%' : '${c.discountValue.toStringAsFixed(0)} EGP',
                    style: AppTextStyles.label.copyWith(color: AppColors.accentGreen),
                  )),
                  DataCell(Text(
                    c.minOrderAmount != null ? '${c.minOrderAmount!.toStringAsFixed(0)} EGP' : '—',
                    style: AppTextStyles.body,
                  )),
                  DataCell(Text(
                    c.maxUses != null ? '${c.usedCount}/${c.maxUses}' : '${c.usedCount}/∞',
                    style: AppTextStyles.body,
                  )),
                  DataCell(Text(
                    c.expiresAt != null
                        ? DateFormat('dd/MM/yyyy').format(c.expiresAt!)
                        : context.l10n.noExpiry,
                    style: AppTextStyles.body.copyWith(
                      color: expired ? AppColors.error : null,
                    ),
                  )),
                  DataCell(Switch(
                    value: c.isActive && !expired,
                    onChanged: expired ? null : (_) => onToggle(c),
                    activeColor: AppColors.primaryDark,
                  )),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => onEdit(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () => onDelete(c),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Form Dialog ─────────────────────────────────────────────────────────────

class _CouponFormDialog extends StatefulWidget {
  const _CouponFormDialog({this.coupon});
  final Coupon? coupon;

  @override
  State<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<_CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _value;
  late final TextEditingController _minOrder;
  late final TextEditingController _maxUses;
  late String _type;
  late bool _active;
  DateTime? _expiry;
  bool _saving = false;

  bool get _isEdit => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _code = TextEditingController(text: c?.code ?? '');
    _value = TextEditingController(text: c != null ? c.discountValue.toStringAsFixed(0) : '');
    _minOrder = TextEditingController(text: c?.minOrderAmount?.toStringAsFixed(0) ?? '');
    _maxUses = TextEditingController(text: c?.maxUses?.toString() ?? '');
    _type = c?.discountType ?? 'percentage';
    _active = c?.isActive ?? true;
    _expiry = c?.expiresAt;
  }

  @override
  void dispose() {
    _code.dispose();
    _value.dispose();
    _minOrder.dispose();
    _maxUses.dispose();
    super.dispose();
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    final code = List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
    setState(() => _code.text = code);
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final coupon = Coupon(
      id: widget.coupon?.id ?? '',
      code: _code.text.trim().toUpperCase(),
      discountType: _type,
      discountValue: double.tryParse(_value.text.trim()) ?? 0,
      minOrderAmount: _minOrder.text.trim().isEmpty ? null : double.tryParse(_minOrder.text.trim()),
      maxUses: _maxUses.text.trim().isEmpty ? null : int.tryParse(_maxUses.text.trim()),
      isActive: _active,
      expiresAt: _expiry,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
    );

    final success = await context.read<CouponsCubit>().save(coupon);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? context.l10n.couponUpdated : context.l10n.couponCreated),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.somethingWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEdit ? context.l10n.editCoupon : context.l10n.newCoupon,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 20),

                  // Code + generate button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: context.l10n.couponCodeLabel,
                          controller: _code,
                          validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.requiredField : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: OutlinedButton.icon(
                          onPressed: _generateCode,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: Text(context.l10n.generateCode),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Discount type
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: context.l10n.discountType,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    items: [
                      DropdownMenuItem(value: 'percentage', child: Text(context.l10n.percentageType)),
                      DropdownMenuItem(value: 'fixed', child: Text(context.l10n.fixedType)),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'percentage'),
                  ),
                  const SizedBox(height: 16),

                  // Discount value
                  AppTextField(
                    label: context.l10n.discountValueLabel,
                    controller: _value,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return context.l10n.requiredField;
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return context.l10n.requiredField;
                      if (_type == 'percentage' && n > 100) return 'Max 100%';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Min order
                  AppTextField(
                    label: context.l10n.minOrderAmountLabel,
                    controller: _minOrder,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Max uses
                  AppTextField(
                    label: context.l10n.maxUsesLabel,
                    controller: _maxUses,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Expiry date
                  InkWell(
                    onTap: _pickExpiry,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.expiryDateLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        suffixIcon: _expiry != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _expiry = null),
                              )
                            : const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                      child: Text(
                        _expiry != null
                            ? DateFormat('dd/MM/yyyy').format(_expiry!)
                            : context.l10n.noExpiry,
                        style: AppTextStyles.body.copyWith(
                          color: _expiry != null ? AppColors.ink : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Active toggle
                  Row(
                    children: [
                      Text(context.l10n.active, style: AppTextStyles.label),
                      const Spacer(),
                      Switch(
                        value: _active,
                        onChanged: (v) => setState(() => _active = v),
                        activeColor: AppColors.primaryDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: context.l10n.save,
                          expand: true,
                          loading: _saving,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

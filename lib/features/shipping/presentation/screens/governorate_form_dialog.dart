import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/model/governorate.dart';
import '../cubits/shipping_cubit.dart';

class GovernorateFormDialog extends StatefulWidget {
  const GovernorateFormDialog({super.key, this.governorate});
  final Governorate? governorate;

  @override
  State<GovernorateFormDialog> createState() => _GovernorateFormDialogState();
}

class _GovernorateFormDialogState extends State<GovernorateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.governorate?.name);
  late final _nameAr = TextEditingController(text: widget.governorate?.nameAr);
  late final _cost = TextEditingController(
      text: widget.governorate?.shippingCost.toString());
  late final _days = TextEditingController(
      text: widget.governorate?.deliveryDays.toString() ?? '3');
  late bool _isActive = widget.governorate?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_name, _nameAr, _cost, _days]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final g = Governorate(
      id: widget.governorate?.id ?? '',
      name: _name.text.trim(),
      nameAr: _nameAr.text.trim().isEmpty ? null : _nameAr.text.trim(),
      shippingCost: double.tryParse(_cost.text.trim()) ?? 0,
      deliveryDays: int.tryParse(_days.text.trim()) ?? 3,
      isActive: _isActive,
    );
    final ok = await context.read<ShippingCubit>().save(g);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.somethingWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.governorate == null
                        ? context.l10n.newGovernorate
                        : context.l10n.editGovernorate,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: context.l10n.name,
                    controller: _name,
                    validator: AppValidator.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: context.l10n.nameAr,
                    controller: _nameAr,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: context.l10n.shippingCostLabel,
                    controller: _cost,
                    keyboardType: TextInputType.number,
                    validator: AppValidator.number,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: context.l10n.deliveryDays,
                    controller: _days,
                    keyboardType: TextInputType.number,
                    validator: AppValidator.number,
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primaryDark,
                    title: Text(context.l10n.active, style: AppTextStyles.label),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.l10n.cancel)),
                      const SizedBox(width: 8),
                      AppButton(label: context.l10n.save, onPressed: _save),
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

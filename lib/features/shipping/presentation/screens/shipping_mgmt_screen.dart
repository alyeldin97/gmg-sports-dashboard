import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/model/governorate.dart';
import '../cubits/shipping_cubit.dart';
import 'governorate_form_dialog.dart';

class ShippingMgmtScreen extends StatefulWidget {
  const ShippingMgmtScreen({super.key});

  @override
  State<ShippingMgmtScreen> createState() => _ShippingMgmtScreenState();
}

class _ShippingMgmtScreenState extends State<ShippingMgmtScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShippingCubit>().load();
  }

  void _openForm([Governorate? gov]) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ShippingCubit>(),
        child: GovernorateFormDialog(governorate: gov),
      ),
    );
  }

  Future<void> _confirmDelete(Governorate g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text('${context.l10n.deleteMessage} "${g.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.delete,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) {
      final success = await context.read<ShippingCubit>().delete(g.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? context.l10n.deletedSuccessfully : context.l10n.somethingWrong),
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
              Text(context.l10n.governoratesTitle,
                  style: AppTextStyles.heading3),
              AppButton(
                label: '+ ${context.l10n.newGovernorate}',
                onPressed: () => _openForm(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ShippingCubit, ShippingState>(
              builder: (context, state) {
                if (state.status == ShippingStatus.loading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.status == ShippingStatus.failure &&
                    state.governorates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? context.l10n.somethingWrong,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        AppButton(
                          label: context.l10n.retry,
                          onPressed: () =>
                              context.read<ShippingCubit>().load(),
                        ),
                      ],
                    ),
                  );
                }
                if (state.governorates.isEmpty) {
                  return Center(
                    child: Text(context.l10n.noGovernorates,
                        style: AppTextStyles.label),
                  );
                }
                return _GovernorateTable(
                  governorates: state.governorates,
                  onEdit: _openForm,
                  onDelete: _confirmDelete,
                  onToggle: (g) => context.read<ShippingCubit>().toggleActive(g),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernorateTable extends StatelessWidget {
  const _GovernorateTable({
    required this.governorates,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });
  final List<Governorate> governorates;
  final ValueChanged<Governorate> onEdit;
  final ValueChanged<Governorate> onDelete;
  final ValueChanged<Governorate> onToggle;

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
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.scaffoldBg),
            columns: [
              DataColumn(
                  label: Text(context.l10n.name,
                      style: AppTextStyles.label)),
              DataColumn(
                  label: Text(context.l10n.shippingCostLabel,
                      style: AppTextStyles.label)),
              DataColumn(
                  label: Text(context.l10n.deliveryDays,
                      style: AppTextStyles.label)),
              DataColumn(
                  label: Text(context.l10n.active,
                      style: AppTextStyles.label)),
              const DataColumn(label: Text('')),
            ],
            rows: governorates
                .map((g) => DataRow(cells: [
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(g.name,
                              style: AppTextStyles.label),
                          if (g.nameAr != null && g.nameAr!.isNotEmpty)
                            Text(g.nameAr!,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textLight)),
                        ],
                      )),
                      DataCell(Text('${g.shippingCost.toStringAsFixed(0)} EGP')),
                      DataCell(Text('${g.deliveryDays} d')),
                      DataCell(
                        Switch(
                          value: g.isActive,
                          onChanged: (_) => onToggle(g),
                          activeColor: AppColors.primaryDark,
                        ),
                      ),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => onEdit(g),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.error),
                            onPressed: () => onDelete(g),
                          ),
                        ],
                      )),
                    ]))
                .toList(),
          ),
        ),
      ),
    );
  }
}

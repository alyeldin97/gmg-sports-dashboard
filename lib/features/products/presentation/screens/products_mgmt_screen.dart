import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../collections/presentation/cubits/collections_cubit.dart';
import '../../data/model/product.dart';
import '../cubits/products_cubit.dart';
import 'product_form_screen.dart';

enum _FilterMode { all, active, inactive }

class ProductsMgmtScreen extends StatefulWidget {
  const ProductsMgmtScreen({super.key});

  @override
  State<ProductsMgmtScreen> createState() => _ProductsMgmtScreenState();
}

class _ProductsMgmtScreenState extends State<ProductsMgmtScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _FilterMode _filter = _FilterMode.all;
  final Set<String> _selected = {};
  bool _selectMode = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _applyFilter(List<Product> products) {
    final q = _query.toLowerCase();
    return products.where((p) {
      final matchesSearch = q.isEmpty || p.name.toLowerCase().contains(q) || (p.nameAr?.toLowerCase().contains(q) ?? false);
      final matchesFilter = _filter == _FilterMode.all ||
          (_filter == _FilterMode.active && p.isActive) ||
          (_filter == _FilterMode.inactive && !p.isActive);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _exitSelectMode() => setState(() {
        _selectMode = false;
        _selected.clear();
      });

  void _openForm(BuildContext context, {Product? product}) {
    final productsCubit = context.read<ProductsCubit>();
    final collectionsCubit = context.read<CollectionsCubit>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productsCubit),
          BlocProvider.value(value: collectionsCubit),
        ],
        child: ProductFormScreen(product: product),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.l10n.navProducts, style: AppTextStyles.heading1),
              const Spacer(),
              if (_selectMode) ...[
                TextButton(onPressed: _exitSelectMode, child: Text(context.l10n.cancel)),
                const SizedBox(width: 8),
              ],
              if (!_selectMode)
                AppButton(
                  label: context.l10n.newProduct,
                  icon: Icons.add,
                  onPressed: () => _openForm(context),
                ),
            ],
          ),
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
              DropdownButton<_FilterMode>(
                value: _filter,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: _FilterMode.all, child: Text('All')),
                  DropdownMenuItem(value: _FilterMode.active, child: Text(context.l10n.active)),
                  DropdownMenuItem(value: _FilterMode.inactive, child: Text(context.l10n.inactive)),
                ],
                onChanged: (v) => setState(() => _filter = v ?? _FilterMode.all),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectMode && _selected.isNotEmpty)
            _BulkActionBar(
              selectedIds: _selected.toList(),
              onDone: _exitSelectMode,
            ),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if ((state.status == ProductsStatus.loading || state.status == ProductsStatus.initial || state.status == ProductsStatus.saving) && state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.status == ProductsStatus.failure && state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.somethingWrong, style: AppTextStyles.body),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<ProductsCubit>().load(),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  );
                }
                final filtered = _applyFilter(state.products);
                if (filtered.isEmpty) {
                  return EmptyState(icon: Icons.inventory_2_outlined, title: context.l10n.noProducts);
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
                    itemBuilder: (context, i) => _ProductRow(
                      product: filtered[i],
                      onEdit: () => _openForm(context, product: filtered[i]),
                      selectMode: _selectMode,
                      selected: _selected.contains(filtered[i].id),
                      onLongPress: () => setState(() {
                        _selectMode = true;
                        _selected.add(filtered[i].id);
                      }),
                      onToggleSelect: (v) => setState(() {
                        if (v) {
                          _selected.add(filtered[i].id);
                        } else {
                          _selected.remove(filtered[i].id);
                        }
                      }),
                    ),
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

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({required this.selectedIds, required this.onDone});
  final List<String> selectedIds;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('${selectedIds.length} selected', style: AppTextStyles.subtitle),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Activate'),
            onPressed: () async {
              final cubit = context.read<ProductsCubit>();
              final ok = await cubit.bulkToggleActive(selectedIds, true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Products activated' : 'Failed to update'),
                ));
                onDone();
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.visibility_off_outlined, size: 18),
            label: const Text('Deactivate'),
            onPressed: () async {
              final cubit = context.read<ProductsCubit>();
              final ok = await cubit.bulkToggleActive(selectedIds, false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Products deactivated' : 'Failed to update'),
                ));
                onDone();
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            label: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
            onPressed: () => _confirmBulkDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text('Delete ${selectedIds.length} product(s)? ${context.l10n.deleteMessage}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await cubit.bulkDelete(selectedIds);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Products deleted' : 'Failed to delete'),
                ));
                onDone();
              }
            },
            child: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.selectMode,
    required this.selected,
    required this.onLongPress,
    required this.onToggleSelect,
  });
  final Product product;
  final VoidCallback onEdit;
  final bool selectMode;
  final bool selected;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onToggleSelect;

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.deleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await cubit.delete(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Product deleted' : 'Failed to delete'),
                ));
              }
            },
            child: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (selectMode)
              Checkbox(
                value: selected,
                activeColor: AppColors.primaryDark,
                onChanged: (v) => onToggleSelect(v ?? false),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(url: product.primaryImage, width: 48, height: 48),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.subtitle),
                  if (product.variants.isNotEmpty)
                    Text('${product.variants.length} ${context.l10n.variants}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Expanded(child: Text('${product.price.asPrice} ${context.l10n.currency}', style: AppTextStyles.price)),
            Expanded(child: Text('${context.l10n.stock}: ${product.stock}', style: AppTextStyles.bodySmall)),
            if (product.isFeatured)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
              ),
            _Badge(active: product.isActive),
            IconButton(
              icon: Icon(product.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
              tooltip: product.isActive ? context.l10n.inactive : context.l10n.active,
              onPressed: () async {
                final cubit = context.read<ProductsCubit>();
                final ok = await cubit.toggleActive(product);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Product updated' : 'Failed to update'),
                  ));
                }
              },
            ),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentGreen : AppColors.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(active ? context.l10n.active : context.l10n.inactive,
          style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

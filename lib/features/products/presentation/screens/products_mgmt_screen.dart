import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
                  DropdownMenuItem(value: _FilterMode.all, child: Text(context.l10n.allFilter)),
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
          Text(context.l10n.selectedCount(selectedIds.length), style: AppTextStyles.subtitle),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: Text(context.l10n.activate),
            onPressed: () async {
              final cubit = context.read<ProductsCubit>();
              final ok = await cubit.bulkToggleActive(selectedIds, true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? context.l10n.productsActivated : context.l10n.failedToUpdate),
                ));
                onDone();
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.visibility_off_outlined, size: 18),
            label: Text(context.l10n.deactivate),
            onPressed: () async {
              final cubit = context.read<ProductsCubit>();
              final ok = await cubit.bulkToggleActive(selectedIds, false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? context.l10n.productsDeactivated : context.l10n.failedToUpdate),
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
                  content: Text(ok ? context.l10n.productsDeleted : context.l10n.failedToDelete),
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

  void _openStockDialog(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _StockAdjustmentDialog(product: product),
      ),
    );
  }

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
                  content: Text(ok ? context.l10n.productDeleted : context.l10n.failedToDelete),
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
            Expanded(child: _StockBadge(stock: product.stock)),
            IconButton(
              icon: const Icon(Icons.tune, size: 18),
              tooltip: context.l10n.adjustStock,
              onPressed: () => _openStockDialog(context),
            ),
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
                    content: Text(ok ? context.l10n.productUpdated : context.l10n.failedToUpdate),
                  ));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 18),
              tooltip: context.l10n.duplicateProduct,
              onPressed: () async {
                final cubit = context.read<ProductsCubit>();
                final ok = await cubit.duplicate(product);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? context.l10n.productDuplicated : context.l10n.failedToUpdate),
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

// ─── Stock badge (color by level) ─────────────────────────────────────────────

Color stockColor(int stock) {
  if (stock <= 0) return AppColors.error;
  if (stock < 10) return AppColors.accentOrange;
  return AppColors.accentGreen;
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final color = stockColor(stock);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('${context.l10n.stock}: $stock',
            style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── Stock adjustment dialog ──────────────────────────────────────────────────

enum _StockReason { restock, manualAdjustment, damage, returned }

extension _StockReasonX on _StockReason {
  String get dbValue => switch (this) {
        _StockReason.restock => 'restock',
        _StockReason.manualAdjustment => 'manual_adjustment',
        _StockReason.damage => 'damage',
        _StockReason.returned => 'return',
      };

  String label(BuildContext context) => switch (this) {
        _StockReason.restock => context.l10n.restock,
        _StockReason.manualAdjustment => context.l10n.manualAdjustment,
        _StockReason.damage => context.l10n.damageOrLoss,
        _StockReason.returned => context.l10n.returnReason,
      };
}

class _StockAdjustmentDialog extends StatefulWidget {
  const _StockAdjustmentDialog({required this.product});
  final Product product;

  @override
  State<_StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<_StockAdjustmentDialog> {
  _StockReason _reason = _StockReason.restock;
  final _qtyCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  int get _delta => int.tryParse(_qtyCtrl.text.trim()) ?? 0;
  int get _newStock => (widget.product.stock + _delta).clamp(0, 1 << 31);

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _bump(int by) {
    setState(() => _qtyCtrl.text = '${_delta + by}');
  }

  Future<void> _confirm() async {
    final delta = _delta;
    if (delta == 0) {
      Navigator.of(context).pop();
      return;
    }
    final cubit = context.read<ProductsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final successText = context.l10n.stockAdjusted;
    final failText = context.l10n.failedToUpdate;
    setState(() => _saving = true);
    final client = Supabase.instance.client;
    final newStock = _newStock;
    try {
      await client.from('stock_movements').insert({
        'product_id': widget.product.id,
        'quantity_change': delta,
        'reason': _reason.dbValue,
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'created_by': client.auth.currentUser?.email,
      });
      await client.from('products').update({'stock': newStock}).eq('id', widget.product.id);
      cubit.updateStock(widget.product.id, newStock);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(successText)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('$failText: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${context.l10n.adjustStock} — ${widget.product.name}',
          style: AppTextStyles.heading3),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${context.l10n.currentStock}: ', style: AppTextStyles.label),
                Text('${widget.product.stock}',
                    style: AppTextStyles.subtitle.copyWith(color: stockColor(widget.product.stock))),
                const Spacer(),
                Text('→ $_newStock',
                    style: AppTextStyles.subtitle.copyWith(color: stockColor(_newStock))),
              ],
            ),
            const SizedBox(height: 16),
            Text(context.l10n.reason, style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<_StockReason>(
              initialValue: _reason,
              isDense: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: [
                for (final r in _StockReason.values)
                  DropdownMenuItem(value: r, child: Text(r.label(context))),
              ],
              onChanged: (v) => setState(() => _reason = v ?? _StockReason.restock),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.quantityChange, style: AppTextStyles.label),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton.outlined(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _bump(-1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.add),
                  onPressed: () => _bump(1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(context.l10n.notes, style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _confirm,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(context.l10n.save, style: const TextStyle(color: AppColors.ink)),
        ),
      ],
    );
  }
}

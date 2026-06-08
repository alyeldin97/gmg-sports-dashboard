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

class ProductsMgmtScreen extends StatelessWidget {
  const ProductsMgmtScreen({super.key});

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
              AppButton(
                label: context.l10n.newProduct,
                icon: Icons.add,
                onPressed: () => _openForm(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state.status == ProductsStatus.loading || state.status == ProductsStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.products.isEmpty) {
                  return EmptyState(icon: Icons.inventory_2_outlined, title: context.l10n.noProducts);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, i) => _ProductRow(
                      product: state.products[i],
                      onEdit: () => _openForm(context, product: state.products[i]),
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

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onEdit});
  final Product product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
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
            onPressed: () => context.read<ProductsCubit>().toggleActive(product),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
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
            onPressed: () {
              cubit.delete(product.id);
              Navigator.pop(dialogCtx);
            },
            child: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
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

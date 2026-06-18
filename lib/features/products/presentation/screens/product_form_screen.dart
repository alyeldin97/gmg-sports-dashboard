import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../collections/presentation/cubits/collections_cubit.dart';
import '../../data/model/product.dart';
import '../../data/model/product_variant.dart';
import '../cubits/products_cubit.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _VariantRow {
  _VariantRow({this.id = '', String name = '', String? price, int stock = 0})
      : name = TextEditingController(text: name),
        price = TextEditingController(text: price),
        stock = TextEditingController(text: '$stock');
  final String id;
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController stock;

  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
  }
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _nameAr = TextEditingController(text: widget.product?.nameAr);
  late final _desc = TextEditingController(text: widget.product?.description);
  late final _descAr = TextEditingController(text: widget.product?.descriptionAr);
  late final _price = TextEditingController(text: widget.product?.price.toString());
  late final _compareAt = TextEditingController(text: widget.product?.compareAtPrice?.toString());
  late final _stock = TextEditingController(text: '${widget.product?.stock ?? 0}');
  late final _images = TextEditingController(text: widget.product?.images.join('\n'));
  late bool _isActive = widget.product?.isActive ?? true;
  late bool _isFeatured = widget.product?.isFeatured ?? false;
  late final Set<String> _collectionIds = {...?widget.product?.collectionIds};
  late final List<_VariantRow> _variants = [
    ...?widget.product?.variants.map((v) =>
        _VariantRow(id: v.id, name: v.name, price: v.price?.toString(), stock: v.stock)),
  ];

  @override
  void dispose() {
    for (final c in [_name, _nameAr, _desc, _descAr, _price, _compareAt, _stock, _images]) {
      c.dispose();
    }
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final variants = _variants
        .where((v) => v.name.text.trim().isNotEmpty)
        .map((v) => ProductVariant(
              id: v.id,
              name: v.name.text.trim(),
              price: double.tryParse(v.price.text.trim()),
              stock: int.tryParse(v.stock.text.trim()) ?? 0,
            ))
        .toList();

    final product = (widget.product ?? const Product(name: '')).copyWith(
      name: _name.text.trim(),
      nameAr: _nameAr.text.trim(),
      description: _desc.text.trim(),
      descriptionAr: _descAr.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      compareAtPrice: double.tryParse(_compareAt.text.trim()),
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      images: _images.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      isActive: _isActive,
      isFeatured: _isFeatured,
      collectionIds: _collectionIds.toList(),
      variants: variants,
    );

    final ok = await context.read<ProductsCubit>().save(product);
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.product == null ? context.l10n.newProduct : context.l10n.editProduct,
            style: AppTextStyles.heading3),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _row([
                  AppTextField(label: context.l10n.name, controller: _name, validator: AppValidator.required),
                  AppTextField(label: context.l10n.nameAr, controller: _nameAr),
                ]),
                const SizedBox(height: 16),
                AppTextField(label: context.l10n.description, controller: _desc, maxLines: 3),
                const SizedBox(height: 16),
                AppTextField(label: context.l10n.descriptionAr, controller: _descAr, maxLines: 3),
                const SizedBox(height: 16),
                _row([
                  AppTextField(label: context.l10n.price, controller: _price, validator: AppValidator.number, keyboardType: TextInputType.number),
                  AppTextField(label: context.l10n.compareAtPrice, controller: _compareAt, keyboardType: TextInputType.number, validator: AppValidator.optionalNumber),
                  AppTextField(label: context.l10n.stock, controller: _stock, keyboardType: TextInputType.number, validator: AppValidator.optionalNumber),
                ]),
                const SizedBox(height: 16),
                AppTextField(
                  label: context.l10n.imageUrls,
                  controller: _images,
                  maxLines: 3,
                  hint: 'https://…',
                  validator: (v) {
                    final lines = (v ?? '').split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
                    for (final line in lines) {
                      final err = AppValidator.url(line);
                      if (err != null) return err;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primaryDark,
                        title: Text(context.l10n.active, style: AppTextStyles.label),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primaryDark,
                        title: Text(context.l10n.featured, style: AppTextStyles.label),
                        value: _isFeatured,
                        onChanged: (v) => setState(() => _isFeatured = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(context.l10n.collectionsLabel, style: AppTextStyles.label),
                const SizedBox(height: 8),
                BlocBuilder<CollectionsCubit, CollectionsState>(
                  builder: (context, state) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.collections.map((c) {
                      final selected = _collectionIds.contains(c.id);
                      return FilterChip(
                        label: Text(c.title),
                        selected: selected,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.ink,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _collectionIds.add(c.id);
                          } else {
                            _collectionIds.remove(c.id);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(context.l10n.variants, style: AppTextStyles.heading3),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(() => _variants.add(_VariantRow())),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(context.l10n.addVariant),
                    ),
                  ],
                ),
                ..._variants.asMap().entries.map((e) => _variantRow(e.key, e.value)),
                const SizedBox(height: 24),
                BlocBuilder<ProductsCubit, ProductsState>(
                  builder: (context, state) => AppButton(
                    label: context.l10n.save,
                    expand: true,
                    loading: state.status == ProductsStatus.saving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _variantRow(int index, _VariantRow v) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 3, child: AppTextField(label: context.l10n.variantName, controller: v.name)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AppTextField(label: context.l10n.price, controller: v.price, keyboardType: TextInputType.number, validator: AppValidator.optionalNumber)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AppTextField(label: context.l10n.stock, controller: v.stock, keyboardType: TextInputType.number, validator: AppValidator.optionalNumber)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
            onPressed: () => setState(() {
              _variants.removeAt(index).dispose();
            }),
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

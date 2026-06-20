import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  late List<String> _images = [...?widget.product?.images];
  late bool _isActive = widget.product?.isActive ?? true;
  late bool _isFeatured = widget.product?.isFeatured ?? false;
  late final Set<String> _collectionIds = {...?widget.product?.collectionIds};
  late final List<_VariantRow> _variants = [
    ...?widget.product?.variants.map((v) =>
        _VariantRow(id: v.id, name: v.name, price: v.price?.toString(), stock: v.stock)),
  ];

  @override
  void dispose() {
    for (final c in [_name, _nameAr, _desc, _descAr, _price, _compareAt, _stock]) {
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
      images: _images,
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
                _ImagePickerSection(
                  images: _images,
                  onChanged: (urls) => setState(() => _images = urls),
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

// ─── Image upload section ─────────────────────────────────────────────────────

class _ImagePickerSection extends StatefulWidget {
  const _ImagePickerSection({required this.images, required this.onChanged});
  final List<String> images;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<_ImagePickerSection> {
  static const _allowedExt = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
  static const _maxBytes = 5 * 1024 * 1024;

  // Number of files currently uploading (per-file spinners).
  int _uploadingCount = 0;
  bool _dragHovering = false;

  bool get _uploading => _uploadingCount > 0;

  Future<void> _pickFromDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;
    await _uploadFiles(result.files);
  }

  /// Validates a single file. Returns an error message key text, or null if ok.
  String? _validate(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    if (ext == null || !_allowedExt.contains(ext)) {
      return context.l10n.invalidImageType;
    }
    final bytes = file.bytes;
    if (bytes == null || bytes.length >= _maxBytes) {
      return context.l10n.imageTooLarge;
    }
    return null;
  }

  Future<void> _uploadFiles(List<PlatformFile> files) async {
    final storage = Supabase.instance.client.storage;
    final urls = List<String>.from(widget.images);

    for (final file in files) {
      final error = _validate(file);
      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${file.name}: $error')),
          );
        }
        continue;
      }
      setState(() => _uploadingCount++);
      try {
        final ext = file.extension!.toLowerCase();
        final path = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        await storage.from('product-images').uploadBinary(
              path,
              file.bytes!,
              fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
            );
        urls.add(storage.from('product-images').getPublicUrl(path));
        widget.onChanged(List<String>.from(urls));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _uploadingCount--);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.productImages, style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (widget.images.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.images.map((url) => _ImageThumb(
                    url: url,
                    onRemove: () {
                      final updated = List<String>.from(widget.images)..remove(url);
                      widget.onChanged(updated);
                    },
                  )),
              // One spinner thumb per in-flight upload.
              for (var i = 0; i < _uploadingCount; i++)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMist,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Drag & drop target wrapping the click-to-upload area (web friendly).
        DragTarget<Object>(
          onWillAcceptWithDetails: (_) {
            setState(() => _dragHovering = true);
            return true;
          },
          onLeave: (_) => setState(() => _dragHovering = false),
          onAcceptWithDetails: (_) => setState(() => _dragHovering = false),
          builder: (context, candidate, rejected) {
            final hovering = _dragHovering || candidate.isNotEmpty;
            return InkWell(
              onTap: _uploading ? null : _pickFromDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                decoration: BoxDecoration(
                  color: hovering
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hovering ? AppColors.primaryDark : AppColors.border,
                    width: hovering ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    if (_uploading)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                      )
                    else
                      const Icon(Icons.cloud_upload_outlined, size: 30, color: AppColors.primaryDark),
                    const SizedBox(height: 10),
                    Text(
                      _uploading ? context.l10n.uploading : context.l10n.dropImagesHere,
                      style: AppTextStyles.label,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.url, required this.onRemove});
  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: AppColors.primaryMist,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined,
                  color: AppColors.textLight, size: 28),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

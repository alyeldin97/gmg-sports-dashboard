import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/model/banner_item.dart';
import '../cubits/banners_cubit.dart';

class BannerFormDialog extends StatefulWidget {
  const BannerFormDialog({super.key, this.banner});
  final BannerItem? banner;

  @override
  State<BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends State<BannerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.banner?.title);
  late final _linkId = TextEditingController(text: widget.banner?.linkId);
  late final _sort = TextEditingController(text: '${widget.banner?.sortOrder ?? 0}');
  late String _imageUrl = widget.banner?.imageUrl ?? '';
  late String _linkType = widget.banner?.linkType ?? 'none';
  late bool _isActive = widget.banner?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_title, _linkId, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a banner image')),
      );
      return;
    }
    final b = BannerItem(
      id: widget.banner?.id ?? '',
      title: _title.text.trim(),
      imageUrl: _imageUrl,
      linkType: _linkType,
      linkId: _linkId.text.trim(),
      sortOrder: int.tryParse(_sort.text.trim()) ?? 0,
      isActive: _isActive,
    );
    final ok = await context.read<BannersCubit>().save(b);
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
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.banner == null ? context.l10n.newBanner : context.l10n.editBanner,
                      style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  AppTextField(label: context.l10n.title, controller: _title, validator: AppValidator.required),
                  const SizedBox(height: 12),
                  _BannerImagePicker(
                    imageUrl: _imageUrl,
                    onChanged: (url) => setState(() => _imageUrl = url),
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.linkType, style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _linkType,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      DropdownMenuItem(value: 'none', child: Text(context.l10n.linkNone)),
                      DropdownMenuItem(value: 'collection', child: Text(context.l10n.linkCollection)),
                      DropdownMenuItem(value: 'product', child: Text(context.l10n.linkProduct)),
                    ],
                    onChanged: (v) => setState(() => _linkType = v ?? 'none'),
                  ),
                  if (_linkType != 'none') ...[
                    const SizedBox(height: 12),
                    AppTextField(label: context.l10n.linkTargetId, controller: _linkId, validator: AppValidator.required),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(label: context.l10n.sortOrder, controller: _sort, keyboardType: TextInputType.number, validator: AppValidator.number),
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
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
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

class _BannerImagePicker extends StatefulWidget {
  const _BannerImagePicker({required this.imageUrl, required this.onChanged});
  final String imageUrl;
  final ValueChanged<String> onChanged;

  @override
  State<_BannerImagePicker> createState() => _BannerImagePickerState();
}

class _BannerImagePickerState extends State<_BannerImagePicker> {
  bool _uploading = false;

  Future<void> _pick() async {
    if (_uploading) return;
    final completer = Completer<void>();
    js.context.callMethod('gmgPickImages', [
      js.allowInterop((String jsonStr) {
        try {
          final items = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
          final first = items.isNotEmpty ? items.first : null;
          if (first != null && (first['dataUrl'] as String).isNotEmpty) {
            _uploadFile(first)
                .then((_) => completer.complete())
                .catchError((_) => completer.complete());
          } else {
            completer.complete();
          }
        } catch (_) {
          completer.complete();
        }
      }),
    ]);
    await completer.future;
  }

  Future<void> _uploadFile(Map<String, dynamic> file) async {
    final dataUrl = file['dataUrl'] as String;
    final bytes = base64Decode(dataUrl.split(',').last);
    final name = file['name'] as String;
    final ext = name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid image type (jpg, png, webp, gif only)')),
        );
      }
      return;
    }
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large (max 5 MB)')),
        );
      }
      return;
    }
    setState(() => _uploading = true);
    try {
      final storage = Supabase.instance.client.storage;
      final path = 'banners/${DateTime.now().millisecondsSinceEpoch}_$name';
      await storage.from('product-images').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
      );
      final url = storage.from('product-images').getPublicUrl(path);
      widget.onChanged(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Banner Image', style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (widget.imageUrl.isNotEmpty) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => widget.onChanged(''),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: _uploading ? null : _pick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
              color: AppColors.scaffoldBg,
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
                  const Icon(Icons.cloud_upload_outlined, size: 26, color: AppColors.primaryDark),
                const SizedBox(height: 6),
                Text(
                  _uploading
                      ? 'Uploading…'
                      : (widget.imageUrl.isNotEmpty ? 'Replace image' : 'Upload banner image'),
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

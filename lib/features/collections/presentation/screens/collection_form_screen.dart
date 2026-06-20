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
import '../../data/model/collection.dart';
import '../cubits/collections_cubit.dart';

class CollectionFormDialog extends StatefulWidget {
  const CollectionFormDialog({super.key, this.collection});
  final Collection? collection;

  @override
  State<CollectionFormDialog> createState() => _CollectionFormDialogState();
}

class _CollectionFormDialogState extends State<CollectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.collection?.title);
  late final _titleAr = TextEditingController(text: widget.collection?.titleAr);
  late String _imageUrl = widget.collection?.imageUrl ?? '';
  late final _sort = TextEditingController(text: '${widget.collection?.sortOrder ?? 0}');
  late bool _isActive = widget.collection?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_title, _titleAr, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final c = Collection(
      id: widget.collection?.id ?? '',
      title: _title.text.trim(),
      titleAr: _titleAr.text.trim(),
      imageUrl: _imageUrl.trim(),
      sortOrder: int.tryParse(_sort.text.trim()) ?? 0,
      isActive: _isActive,
    );
    final ok = await context.read<CollectionsCubit>().save(c);
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
                  Text(widget.collection == null ? context.l10n.newCollection : context.l10n.editCollection,
                      style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  AppTextField(label: context.l10n.title, controller: _title, validator: AppValidator.required),
                  const SizedBox(height: 12),
                  AppTextField(label: context.l10n.titleAr, controller: _titleAr),
                  const SizedBox(height: 12),
                  _CollectionImagePicker(
                    imageUrl: _imageUrl,
                    onChanged: (url) => setState(() => _imageUrl = url),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: context.l10n.sortOrder, controller: _sort, keyboardType: TextInputType.number),
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

// ─── Single-image upload for collections ──────────────────────────────────────

class _CollectionImagePicker extends StatefulWidget {
  const _CollectionImagePicker({required this.imageUrl, required this.onChanged});
  final String imageUrl;
  final ValueChanged<String> onChanged;

  @override
  State<_CollectionImagePicker> createState() => _CollectionImagePickerState();
}

class _CollectionImagePickerState extends State<_CollectionImagePicker> {
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
            _uploadFile(first).then((_) => completer.complete()).catchError((_) => completer.complete());
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
          SnackBar(content: Text(context.l10n.invalidImageType)),
        );
      }
      return;
    }
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.imageTooLarge)),
        );
      }
      return;
    }
    setState(() => _uploading = true);
    try {
      final storage = Supabase.instance.client.storage;
      final path = '${DateTime.now().millisecondsSinceEpoch}_$name';
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
        Text(context.l10n.imageUrl, style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (widget.imageUrl.isNotEmpty) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox(
                    height: 140,
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => widget.onChanged(''),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
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
            padding: const EdgeInsets.symmetric(vertical: 20),
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
                  const Icon(Icons.cloud_upload_outlined, size: 28, color: AppColors.primaryDark),
                const SizedBox(height: 8),
                Text(
                  _uploading ? context.l10n.uploading : context.l10n.dropImagesHere,
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

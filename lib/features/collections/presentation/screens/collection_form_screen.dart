import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
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
  late final _image = TextEditingController(text: widget.collection?.imageUrl);
  late final _sort = TextEditingController(text: '${widget.collection?.sortOrder ?? 0}');
  late bool _isActive = widget.collection?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_title, _titleAr, _image, _sort]) {
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
      imageUrl: _image.text.trim(),
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
                  AppTextField(
                    label: context.l10n.imageUrl,
                    controller: _image,
                    hint: 'https://…',
                    validator: AppValidator.url,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_image.text.trim().isNotEmpty &&
                      Uri.tryParse(_image.text.trim())?.hasScheme == true) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(url: _image.text.trim(), height: 120),
                    ),
                  ],
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

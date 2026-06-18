import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
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
  late final _image = TextEditingController(text: widget.banner?.imageUrl);
  late final _linkId = TextEditingController(text: widget.banner?.linkId);
  late final _sort = TextEditingController(text: '${widget.banner?.sortOrder ?? 0}');
  late String _linkType = widget.banner?.linkType ?? 'none';
  late bool _isActive = widget.banner?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_title, _image, _linkId, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final b = BannerItem(
      id: widget.banner?.id ?? '',
      title: _title.text.trim(),
      imageUrl: _image.text.trim(),
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
                  AppTextField(label: context.l10n.title, controller: _title),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: context.l10n.imageUrl,
                    controller: _image,
                    validator: AppValidator.url,
                    hint: 'https://…',
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
                    AppTextField(label: context.l10n.linkTargetId, controller: _linkId),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(label: context.l10n.sortOrder, controller: _sort, keyboardType: TextInputType.number),
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

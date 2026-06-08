import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/app_settings.dart';
import '../settings_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryFee = TextEditingController();
  final _threshold = TextEditingController();
  final _instapay = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _deliveryFee.dispose();
    _threshold.dispose();
    _instapay.dispose();
    super.dispose();
  }

  void _hydrate(AppSettings s) {
    if (_initialized) return;
    _deliveryFee.text = s.deliveryFee.toString();
    _threshold.text = s.freeDeliveryThreshold.toString();
    _instapay.text = s.instapayHandle;
    _initialized = true;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SettingsCubit>().save(AppSettings(
          deliveryFee: double.tryParse(_deliveryFee.text.trim()) ?? 0,
          freeDeliveryThreshold: double.tryParse(_threshold.text.trim()) ?? 0,
          instapayHandle: _instapay.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.success || state.status == SettingsStatus.saved) {
          _hydrate(state.settings);
        }
        if (state.status == SettingsStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.settingsSaved)));
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.navSettings, style: AppTextStyles.heading1),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(label: context.l10n.deliveryFee, controller: _deliveryFee, validator: AppValidator.number, keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        AppTextField(label: context.l10n.freeDeliveryThreshold, controller: _threshold, validator: AppValidator.number, keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        AppTextField(label: context.l10n.instapayHandle, controller: _instapay, validator: AppValidator.required),
                        const SizedBox(height: 24),
                        AppButton(
                          label: context.l10n.save,
                          expand: true,
                          loading: state.status == SettingsStatus.saving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

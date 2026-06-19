import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
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
  void initState() {
    super.initState();
    final cubit = context.read<SettingsCubit>();
    if (cubit.state.status == SettingsStatus.initial) {
      cubit.load();
    } else if (cubit.state.status == SettingsStatus.success ||
        cubit.state.status == SettingsStatus.saved) {
      _hydrate(cubit.state.settings);
    }
  }

  @override
  void dispose() {
    _deliveryFee.dispose();
    _threshold.dispose();
    _instapay.dispose();
    super.dispose();
  }

  void _hydrate(AppSettings s) {
    if (_initialized) return;
    _deliveryFee.text = s.deliveryFee.toStringAsFixed(0);
    _threshold.text = s.freeDeliveryThreshold.toStringAsFixed(0);
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(context.l10n.settingsSaved)));
        }
        if (state.status == SettingsStatus.failure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage ?? context.l10n.somethingWrong)));
        }
      },
      builder: (context, state) {
        final loading = state.status == SettingsStatus.loading && !_initialized;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.navSettings, style: AppTextStyles.heading1),
              const SizedBox(height: 24),

              // ── Store Settings ──────────────────────────────────────────
              _SectionCard(
                title: context.l10n.storeSettings,
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: context.l10n.deliveryFee,
                              controller: _deliveryFee,
                              validator: AppValidator.number,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: context.l10n.freeDeliveryThreshold,
                              controller: _threshold,
                              validator: AppValidator.number,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: context.l10n.instapayHandle,
                              controller: _instapay,
                              validator: AppValidator.required,
                            ),
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
              const SizedBox(height: 20),

              // ── Account ─────────────────────────────────────────────────
              _SectionCard(
                title: context.l10n.accountSettings,
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, auth) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.admin_panel_settings_outlined,
                        label: context.l10n.adminEmail,
                        value: auth.user?.email ?? '—',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.read<AuthCubit>().signOut(),
                        icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
                        label: Text(context.l10n.logout,
                            style: const TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subtitle),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textLight),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
            Text(value, style: AppTextStyles.label),
          ],
        ),
      ],
    );
  }
}

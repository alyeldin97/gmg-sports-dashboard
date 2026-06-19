import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../layout/presentation/screens/layout_screen.dart';
import '../cubits/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _kEmailKey = 'dashboard_saved_email';
  static const _kPasswordKey = 'dashboard_saved_password';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _remember = false;
  bool _hasSavedCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kEmailKey);
    final password = prefs.getString(_kPasswordKey);
    if (email != null && password != null && mounted) {
      setState(() {
        _emailCtrl.text = email;
        _passwordCtrl.text = password;
        _remember = true;
        _hasSavedCredentials = true;
      });
      // Auto-submit with saved credentials after frame builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _submit();
      });
    }
  }

  Future<void> _persistCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setString(_kEmailKey, _emailCtrl.text.trim());
      await prefs.setString(_kPasswordKey, _passwordCtrl.text);
    } else {
      await prefs.remove(_kEmailKey);
      await prefs.remove(_kPasswordKey);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _persistCredentials();
    context.read<AuthCubit>().signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(LayoutScreen.routeName, (_) => false);
          } else if (state.status == AuthStatus.failure) {
            // Saved credentials were wrong — clear them so the user can re-enter
            if (_hasSavedCredentials) {
              SharedPreferences.getInstance().then((p) {
                p.remove(_kEmailKey);
                p.remove(_kPasswordKey);
              });
              setState(() => _hasSavedCredentials = false);
            }
            final msg = state.errorMessage == 'access_denied'
                ? context.l10n.accessDenied
                : (state.errorMessage ?? context.l10n.somethingWrong);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('assets/images/logo.png', height: 90),
                      const SizedBox(height: 16),
                      Text(context.l10n.adminLogin,
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(context.l10n.adminLoginSubtitle,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: context.l10n.email,
                        controller: _emailCtrl,
                        validator: AppValidator.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: context.l10n.password,
                        controller: _passwordCtrl,
                        validator: AppValidator.password,
                        obscure: true,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (v) =>
                                setState(() => _remember = v ?? false),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _remember = !_remember),
                            child: Text(context.l10n.rememberMe,
                                style: AppTextStyles.body),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: context.l10n.signIn,
                        expand: true,
                        loading: state.status == AuthStatus.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

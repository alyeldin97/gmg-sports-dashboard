import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(email: _email.text.trim(), password: _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(LayoutScreen.routeName, (_) => false);
          } else if (state.status == AuthStatus.failure) {
            final msg = state.errorMessage == 'access_denied'
                ? context.l10n.accessDenied
                : (state.errorMessage ?? context.l10n.somethingWrong);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                      Text(context.l10n.adminLogin, style: AppTextStyles.heading2, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(context.l10n.adminLoginSubtitle,
                          style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: context.l10n.email,
                        controller: _email,
                        validator: AppValidator.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: context.l10n.password,
                        controller: _password,
                        validator: AppValidator.password,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
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

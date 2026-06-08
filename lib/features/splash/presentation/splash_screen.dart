import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/styling/colors.dart';
import '../../auth/presentation/cubits/auth_cubit.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../layout/presentation/screens/layout_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final cubit = context.read<AuthCubit>();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1200)),
      cubit.stream
          .firstWhere((s) => s.status != AuthStatus.loading && s.status != AuthStatus.initial)
          .catchError((_) => cubit.state),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      cubit.state.status == AuthStatus.authenticated
          ? LayoutScreen.routeName
          : LoginScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(child: Image.asset('assets/images/logo.png', width: 220)),
    );
  }
}

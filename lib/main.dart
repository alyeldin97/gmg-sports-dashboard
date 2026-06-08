import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/di/dependency_injection.dart';
import 'core/localization/locale_cubit.dart';
import 'core/navigation/navigation_cubit.dart';
import 'core/styling/colors.dart';
import 'core/utils/configurations.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfigurations.supabaseUrl,
    anonKey: AppConfigurations.supabaseAnonKey,
  );
  runApp(const GmgDashboardApp());
}

class GmgDashboardApp extends StatelessWidget {
  const GmgDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector();
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<AuthCubit>(create: (_) => di.authCubit),
        BlocProvider<NavigationCubit>(create: (_) => di.navigationCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'GMG Sports Admin',
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
              ),
              scaffoldBackgroundColor: AppColors.scaffoldBg,
              useMaterial3: true,
            ),
            onGenerateRoute: RouteGenerator.getRoute,
            initialRoute: RouteGenerator.initialRoute,
          );
        },
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/logging/app_logger.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.setup(
    env: Env.dev,
    revenueCatApiKey: 'test_pgmRCggDrSghPQhlVvtFhoNYElW',
    revenueCatEntitlementId: 'premium',
    requiresAuth: false,
    hasOnboarding: true,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupServiceLocator();

  AppLogger.info('App started in DEV mode');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Design frame: iPhone 14 (390 x 844) — change to your Figma artboard size
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) => BlocProvider<AuthCubit>(
        create: (_) => sl<AuthCubit>(),
        child: MaterialApp.router(
          title: AppConfig.instance.appName,
          debugShowCheckedModeBanner: true,
          theme: AppTheme.build(),
          // darkTheme: AppTheme.buildDark(),
          routerConfig: appRouter,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
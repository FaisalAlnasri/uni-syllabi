import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/logging/app_logger.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/courses/presentation/cubit/course_cubit.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.setup(
    env: Env.prod,
    revenueCatApiKey: Platform.isIOS
        ? 'appl_mzEWugcuEjeJpFemieDhreiZqLR'
        : 'goog_jNZjDkhjtCjtsKUaQerMslcqqsv',
    revenueCatEntitlementId: 'uni syllabi Pro',
    requiresAuth: false,
    hasOnboarding: true,
    syllabusApiBaseUrl: 'https://uni-calendar-backend.vercel.app',
  );

  // Local storage + Arabic date formatting (used across the courses feature).
  await Hive.initFlutter();
  Intl.defaultLocale = 'ar';
  await initializeDateFormatting('ar');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupServiceLocator();

  // Seed/load persisted courses before first frame.
  await sl<CourseCubit>().load();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  AppLogger.info('App started in PROD mode');

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
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
          BlocProvider<CourseCubit>(create: (_) => sl<CourseCubit>()),
          BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp.router(
            title: AppConfig.instance.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(),
            darkTheme: AppTheme.buildDark(),
            themeMode: themeMode,
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
      ),
    );
  }
}

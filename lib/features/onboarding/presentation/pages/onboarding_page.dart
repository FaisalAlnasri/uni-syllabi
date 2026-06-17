import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Placeholder onboarding screen. Replace the body per app — the only
/// requirement is that finishing it calls [OnboardingStorage.setComplete].
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'مرحباً بك',
                style: context.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await sl<OnboardingStorage>().setComplete();
                  if (context.mounted) context.go(AppRoutes.home);
                },
                child: const Text('ابدأ'),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

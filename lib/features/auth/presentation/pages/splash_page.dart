import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Shown while auth state is still unknown. The router redirect navigates
/// away from here once the auth state resolves — no logic lives in this page.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }
}

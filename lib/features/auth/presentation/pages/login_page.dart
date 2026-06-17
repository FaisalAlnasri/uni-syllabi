import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../cubit/auth_cubit.dart';
import '../../domain/entities/auth_state.dart';
import '../auth_strings.dart';
import '../widgets/apple_sign_in_button.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _error;
  late AuthCubit _authCubit; 

  @override
  void initState() {
    super.initState();
    // Capture sign-in failures inline. Cleared again in dispose.
    _authCubit = context.read<AuthCubit>();
    _authCubit.onAuthError = (message) {
      if (!mounted) return;
      setState(() {
        _error = message;
        _isLoading = false;
      });
    };
  }

  @override
  void dispose() {
    _authCubit.onAuthError = null;
    super.dispose();
  }

  Future<void> _signIn(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await action();
    // On success the auth stream drives navigation; on failure onAuthError
    // already reset _isLoading. Guard against a still-mounted spinner.
    if (mounted && _error == null && _isLoading) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        // Authenticated/Guest transitions are handled by the router redirect;
        // nothing to do here beyond letting it rebuild.
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: context.pagePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _AppIcon(),
                  SizedBox(height: 24.h),
                  Text(
                    AppConfig.instance.appName,
                    style: context.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AuthStrings.tagline,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.outline),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  GoogleSignInButton(
                    isLoading: _isLoading,
                    onPressed: _isLoading
                        ? null
                        : () => _signIn(cubit.signInWithGoogle),
                  ),
                  if (Platform.isIOS) ...[
                    SizedBox(height: 12.h),
                    AppleSignInButton(
                      isLoading: _isLoading,
                      onPressed: _isLoading
                          ? null
                          : () => _signIn(cubit.signInWithApple),
                    ),
                  ],
                  if (_error != null) ...[
                    SizedBox(height: 16.h),
                    Text(
                      _error!,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── App icon placeholder ─────────────────────────────────────────────────────

class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final initial =
        AppConfig.instance.appName.trim().isNotEmpty
            ? AppConfig.instance.appName.trim().characters.first
            : '?';

    return Container(
      width: 96.r,
      height: 96.r,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.textTheme.displayLarge?.copyWith(
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}

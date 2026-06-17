import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final user = cubit.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
      ),
      body: ListView(
        padding: context.pagePadding.copyWith(top: 24.h, bottom: 40.h),
        children: [

          // ── Avatar + user info ────────────────────────────────
          Center(
            child: Column(
              children: [
                _Avatar(photoUrl: user?.photoUrl, displayName: user?.displayName),
                SizedBox(height: 12.h),
                if (user?.displayName != null)
                  Text(
                    user!.displayName!,
                    style: context.textTheme.headlineMedium,
                  ),
                if (user?.email != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    user!.email!,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.outline),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // ── Debug tools (dev only) ────────────────────────────
          if (AppConfig.instance.isDev) ...[
            _SectionLabel('أدوات المطوّر'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              label: 'معاينة التصميم',
              onTap: () => context.push(AppRoutes.themePage),
            ),
            SizedBox(height: 24.h),
          ],

          // ── Account ───────────────────────────────────────────
          _SectionLabel('الحساب'),
          _SettingsTile(
            icon: Icons.logout,
            label: 'تسجيل الخروج',
            isDestructive: true,
            onTap: () => _confirmSignOut(context, cubit),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AuthCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'خروج',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.signOut();
    }
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;

  const _Avatar({this.photoUrl, this.displayName});

  @override
  Widget build(BuildContext context) {
    final initial = displayName?.trim().isNotEmpty == true
        ? displayName!.trim().characters.first
        : '?';

    return CircleAvatar(
      radius: 48.r,
      backgroundColor: context.colors.primaryContainer,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initial,
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: context.textTheme.labelMedium
            ?.copyWith(color: context.colors.outline),
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? context.colors.error
        : context.colors.onSurface;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(color: color),
        ),
        trailing: Icon(
          Icons.chevron_left,
          color: context.colors.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}
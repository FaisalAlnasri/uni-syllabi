import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../courses/presentation/cubit/course_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final user = cubit.currentUser;
    final courseCount = context.watch<CourseCubit>().state.courses.length;

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

          // ── Premium upsell ────────────────────────────────────
          _SectionLabel('العضوية'),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            label: 'ترقية إلى المميّز',
            onTap: () => context.push(AppRoutes.paywall),
          ),

          SizedBox(height: 24.h),

          // ── Appearance ────────────────────────────────────────
          _SectionLabel('المظهر'),
          const _AppearanceCard(),

          SizedBox(height: 24.h),

          // ── About ─────────────────────────────────────────────
          _SectionLabel('حول التطبيق'),
          _InfoTile(
            icon: Icons.menu_book_outlined,
            label: 'الدورات المتتبعة',
            value: '$courseCount',
          ),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            label: 'الإصدار',
            value: '1.0.0',
          ),

          // ── Debug tools (dev only) ────────────────────────────
          if (AppConfig.instance.isDev) ...[
            SizedBox(height: 24.h),
            _SectionLabel('أدوات المطوّر'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              label: 'معاينة التصميم',
              onTap: () => context.push(AppRoutes.themePage),
            ),
          ],

          SizedBox(height: 24.h),

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

// ── Appearance (theme mode switch wired to ThemeCubit) ──────────────────────────

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    final themeCubit = context.read<ThemeCubit>();

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            label: 'تلقائي',
            selected: mode == ThemeMode.system,
            onTap: () => themeCubit.setMode(ThemeMode.system),
          ),
          const Divider(height: 1),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: 'فاتح',
            selected: mode == ThemeMode.light,
            onTap: () => themeCubit.setMode(ThemeMode.light),
          ),
          const Divider(height: 1),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: 'داكن',
            selected: mode == ThemeMode.dark,
            onTap: () => themeCubit.setMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? context.colors.primary : context.colors.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: context.textTheme.bodyLarge?.copyWith(color: color),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: context.colors.primary)
          : null,
      onTap: onTap,
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

// ── Info tile (read-only) ───────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(icon, color: context.colors.onSurface),
        title: Text(label, style: context.textTheme.bodyLarge),
        trailing: Text(
          value,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.colors.outline),
        ),
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

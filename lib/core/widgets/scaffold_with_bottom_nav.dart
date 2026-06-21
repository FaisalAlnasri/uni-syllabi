import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../../features/paywall/domain/subscription.dart';
import '../../features/courses/data/services/syllabus_parser_service.dart';
import '../../features/courses/presentation/courses_strings.dart';
import '../../features/courses/presentation/widgets/add_action_sheet.dart';
import '../../features/courses/presentation/widgets/course_form_sheet.dart';
import '../../features/courses/presentation/widgets/deliverable_form_sheet.dart';
import '../../features/courses/presentation/widgets/syllabus_upload_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Hosts the 4 bottom-nav tabs (Timeline, Calendar, Courses, Profile) and the
/// center-docked syllabus-upload FAB. Replaces the source app's `AppShell`.
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  Future<void> _openUpload(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final signedIn = await context.push<bool>(AppRoutes.login);
      if (signedIn == null || signedIn == false) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "يجب تسجيل الدخول لتحليل المنهج الدراسي. يرجى المحاولة مرة أخرى.",
              ),
            ),
          );
        }
        return;
      }
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) =>
          SyllabusUploadDialog(service: sl<SyllabusParserService>()),
    );
  }

  /// Shows the "+" menu and routes to the chosen flow: upload a syllabus, add a
  /// deliverable to an existing course, or create a brand-new course.
  Future<void> _openAddMenu(BuildContext context) async {
    final action = await showAddActionSheet(context);
    if (action == null || !context.mounted) return;
    switch (action) {
      case AddAction.syllabus:
        // AI syllabus parser is premium-gated.
        if (!sl<PurchasesRepository>().isSubscriber) {
          context.push(AppRoutes.paywall);
          return;
        }
        await _openUpload(context);
      case AddAction.deliverable:
        await showAddDeliverableSheet(context);
      case AddAction.course:
        await showCreateCourseSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: _AddButton(onTap: () => _openAddMenu(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(index: _selectedIndex(context)),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.calendar)) return 1;
    if (location.startsWith(AppRoutes.courses)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }
}

// ── Add (syllabus) button ─────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int index;

  const _BottomNav({required this.index});

  void _go(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.calendar);
      case 2:
        context.go(AppRoutes.courses);
      case 3:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.timeline_rounded,
                label: CoursesStrings.tabTimeline,
                selected: index == 0,
                onTap: () => _go(context, 0),
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: CoursesStrings.tabCalendar,
                selected: index == 1,
                onTap: () => _go(context, 1),
              ),
              const SizedBox(width: 64), // FAB notch space
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: CoursesStrings.tabCourses,
                selected: index == 2,
                onTap: () => _go(context, 2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: CoursesStrings.tabProfile,
                selected: index == 3,
                onTap: () => _go(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = selected ? c.accent : c.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

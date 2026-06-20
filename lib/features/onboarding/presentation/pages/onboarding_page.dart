import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../onboarding_strings.dart';

/// Multi-page onboarding that explains the app. Finishing it must call
/// [OnboardingStorage.setComplete] before routing home.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  final AnalyticsService _analytics = sl<AnalyticsService>();
  int _index = 0;
  bool _notificationShownLogged = false;

  // The final slide is the notification opt-in step — it swaps the single
  // "next" button for explicit accept/skip actions.
  static const _pages = <_OnboardingSlide>[
    _OnboardingSlide(
      icon: Icons.school_outlined,
      title: OnboardingStrings.welcomeTitle,
      body: OnboardingStrings.welcomeBody,
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      title: OnboardingStrings.scheduleTitle,
      body: OnboardingStrings.scheduleBody,
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome_outlined,
      title: OnboardingStrings.parserTitle,
      body: OnboardingStrings.parserBody,
    ),
    _OnboardingSlide(
      icon: Icons.calendar_month_outlined,
      title: OnboardingStrings.calendarTitle,
      body: OnboardingStrings.calendarBody,
    ),
    _OnboardingSlide(
      icon: Icons.notification_add_outlined,
      title: OnboardingStrings.notificationsTitle,
      body: OnboardingStrings.notificationsBody,
    ),
  ];

  /// The notification opt-in is the last slide.
  bool get _isNotificationStep => _index == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _analytics.logEvent(AnalyticsEvents.onboardingStarted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    // Log the opt-in impression once, when the step first becomes visible.
    if (i == _pages.length - 1 && !_notificationShownLogged) {
      _notificationShownLogged = true;
      _analytics.logEvent(AnalyticsEvents.notificationShown);
    }
  }

  Future<void> _finish() async {
    _analytics.logEvent(AnalyticsEvents.onboardingCompleted);
    await sl<OnboardingStorage>().setComplete();
    // End on the optional auth page; the user can sign in or continue as guest.
    if (mounted) context.go('${AppRoutes.login}?from=onboarding');
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _acceptNotifications() async {
    _analytics.logEvent(AnalyticsEvents.notificationAccepted);
    // Fire the OS prompt; we proceed regardless of the user's choice.
    await sl<NotificationService>().requestPermission();
    await _finish();
  }

  Future<void> _skipNotifications() async {
    _analytics.logEvent(AnalyticsEvents.notificationSkipped);
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _isNotificationStep ? null : _finish,
                  child: Opacity(
                    opacity: _isNotificationStep ? 0 : 1,
                    child: const Text(OnboardingStrings.skipButton),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, i) => _SlideView(slide: _pages[i]),
                ),
              ),
              _Dots(count: _pages.length, index: _index),
              SizedBox(height: 24.h),
              if (_isNotificationStep)
                _NotificationActions(
                  onAccept: _acceptNotifications,
                  onSkip: _skipNotifications,
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    child: const Text(OnboardingStrings.nextButton),
                  ),
                ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(slide.icon, size: 96.sp, color: context.colors.primary),
        SizedBox(height: 40.h),
        Text(
          slide.title,
          style: context.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Text(
          slide.body,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NotificationActions extends StatelessWidget {
  const _NotificationActions({required this.onAccept, required this.onSkip});

  final VoidCallback onAccept;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onAccept,
            child: const Text(OnboardingStrings.enableNotificationsButton),
          ),
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: onSkip,
          child: const Text(OnboardingStrings.skipNotificationsButton),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: active ? 20.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: active
                ? context.colors.primary
                : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

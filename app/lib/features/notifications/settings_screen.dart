import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/permission_handler.dart';
import '../../l10n/generated/app_localizations.dart';
import 'providers/notifications_provider.dart';

/// Notification settings screen.
///
/// Layout:
///   1. Permission status banner (only if not granted)
///   2. Master switch
///   3. Water section (3 toggles)
///   4. Meals section
///   5. Habits section
///   6. Sleep section (toggle + bedtime picker)
///   7. Coaching section (streak / AI / weekly recap)
///   8. Developer section (debug builds only)
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  static const route = '/settings/notifications';

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
  NotificationPermissionStatus? _permissionStatus;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final service = ref.read(notificationServiceProvider);
    final status = await service.permissions.check();
    if (!mounted) return;
    setState(() {
      _permissionStatus = status;
      _checking = false;
    });
  }

  Future<void> _requestPermission() async {
    final service = ref.read(notificationServiceProvider);
    final status = await service.permissions.request();
    if (!mounted) return;
    setState(() => _permissionStatus = status);

    if (status == NotificationPermissionStatus.permanentlyDenied) {
      await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10nCtx = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10nCtx?.notifOpenSystemSettingsTitle ??
              'Open system settings?'),
          content: Text(
            l10nCtx?.notifOpenSystemSettingsBody ??
                'You denied notifications. Open Settings to turn them back on.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10nCtx?.commonCancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10nCtx?.notifOpenSettings ?? 'Open Settings'),
            ),
          ],
        );
      },
    );
    if (go ?? false) {
      await ref
          .read(notificationServiceProvider)
          .permissions
          .openSystemSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        title: Text(l10n?.notifScreenTitle ?? 'Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (_checking)
              const _Loader()
            else if (_permissionStatus != NotificationPermissionStatus.granted)
              _PermissionBanner(
                status: _permissionStatus!,
                onRequest: _requestPermission,
              ),

            const SizedBox(height: 16),

            _Section(
              title: l10n?.notifAllNotifications ?? 'All notifications',
              child: _ToggleTile(
                title: l10n?.notifMasterSwitch ??
                    'Enable Nuveli notifications',
                subtitle: l10n?.notifMasterSwitchDesc ??
                    'Master switch for everything below.',
                value: settings.masterEnabled,
                onChanged: controller.setMasterEnabled,
              ),
            ),

            _DisabledWrapper(
              disabled: !settings.masterEnabled,
              child: Column(
                children: [
                  _Section(
                    title: l10n?.notifWaterSection ?? 'Water',
                    child: Column(
                      children: [
                        _ToggleTile(
                          title:
                              l10n?.notifWaterMorning ?? 'Morning · 9:00 AM',
                          subtitle: l10n?.notifWaterMorningDesc ??
                              'Kickstart your hydration.',
                          value: settings.waterMorning,
                          onChanged: controller.setWaterMorning,
                        ),
                        _ToggleTile(
                          title: l10n?.notifWaterAfternoon ??
                              'Afternoon · 1:00 PM',
                          subtitle: l10n?.notifWaterAfternoonDesc ??
                              'Mid-day reminder.',
                          value: settings.waterAfternoon,
                          onChanged: controller.setWaterAfternoon,
                        ),
                        _ToggleTile(
                          title: l10n?.notifWaterEvening ??
                              'Evening · 6:30 PM',
                          subtitle: l10n?.notifWaterEveningDesc ??
                              'Wind-down sip.',
                          value: settings.waterEvening,
                          onChanged: controller.setWaterEvening,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  _Section(
                    title: l10n?.notifMealsSection ?? 'Meals',
                    child: _ToggleTile(
                      title: l10n?.notifMealsTitle ??
                          'Lunch & dinner reminders',
                      subtitle: l10n?.notifMealsDesc ??
                          '12:30 PM and 7:00 PM nudges to log.',
                      value: settings.mealReminders,
                      onChanged: controller.setMealReminders,
                    ),
                  ),

                  _Section(
                    title: l10n?.notifHabitsSection ?? 'Habits',
                    child: _ToggleTile(
                      title:
                          l10n?.notifHabitsTitle ?? 'Habit reminders',
                      subtitle: l10n?.notifHabitsDesc ??
                          'Per-habit nudges at the time you picked.',
                      value: settings.habitReminders,
                      onChanged: controller.setHabitReminders,
                    ),
                  ),

                  _Section(
                    title: l10n?.notifSleepSection ?? 'Sleep',
                    child: Column(
                      children: [
                        _ToggleTile(
                          title: l10n?.notifSleepTitle ??
                              'Wind-down reminder',
                          subtitle: l10n?.notifSleepDesc ??
                              '30 minutes before your bedtime.',
                          value: settings.sleepReminder,
                          onChanged: controller.setSleepReminder,
                        ),
                        if (settings.sleepReminder)
                          _BedtimeTile(
                            bedtime: settings.bedtime,
                            onChanged: controller.setBedtime,
                            label:
                                l10n?.notifBedtime ?? 'Bedtime',
                          ),
                      ],
                    ),
                  ),

                  _Section(
                    title:
                        l10n?.notifCoachingSection ?? 'Coaching',
                    child: Column(
                      children: [
                        _ToggleTile(
                          title: l10n?.notifStreakTitle ??
                              'Streak warning',
                          subtitle: l10n?.notifStreakDesc ??
                              "9:00 PM nudge if you haven't logged today.",
                          value: settings.streakWarning,
                          onChanged: controller.setStreakWarning,
                        ),
                        _ToggleTile(
                          title: l10n?.notifAiInsightTitle ??
                              'AI insight ready',
                          subtitle: l10n?.notifAiInsightDesc ??
                              'Morning ping when coaching is fresh.',
                          value: settings.aiInsightReady,
                          onChanged: controller.setAiInsightReady,
                        ),
                        _ToggleTile(
                          title: l10n?.notifWeeklyRecapTitle ??
                              'Weekly recap',
                          subtitle: l10n?.notifWeeklyRecapDesc ??
                              'Sunday 8:00 PM summary.',
                          value: settings.weeklyRecap,
                          onChanged: controller.setWeeklyRecap,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_isDebug)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(
                  onPressed: _sendTestNotification,
                  icon: const Icon(Icons.bug_report_outlined),
                  label: Text(l10n?.notifTestButton ??
                      'Send test notification (10s)'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _isDebug {
    bool debug = false;
    assert(() {
      debug = true;
      return true;
    }());
    return debug;
  }

  Future<void> _sendTestNotification() async {
    await ref.read(notificationServiceProvider).fireTestInTenSeconds();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.notifTestScheduled ??
            'Test notification scheduled in 10s.'),
      ),
    );
  }
}

// ──────────────────── Private widgets ────────────────────

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.status, required this.onRequest});

  final NotificationPermissionStatus status;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final isPermanent =
        status == NotificationPermissionStatus.permanentlyDenied;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2547).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFFFC857).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_outlined,
              color: Color(0xFFFFC857), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.notifPermissionOff ?? 'Notifications are off',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPermanent
                      ? (l10n?.notifPermissionDenied ??
                          'Enable them in system settings to get reminders.')
                      : (l10n?.notifPermissionNotAsked ??
                          "We'll only send what you choose below."),
                  style: const TextStyle(
                    color: Color(0xFFB8C5D6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRequest,
            child: Text(isPermanent
                ? (l10n?.notifPermissionSettings ?? 'Settings')
                : (l10n?.notifPermissionAllow ?? 'Allow')),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF6E7B91),
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF14233E).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0x14FFFFFF)),
              ),
      ),
      child: SwitchListTile.adaptive(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Flutter 3.31+: activeColor deprecated → use activeThumbColor.
        activeThumbColor: const Color(0xFF00D4FF),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFB8C5D6),
              fontSize: 13,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _BedtimeTile extends StatelessWidget {
  const _BedtimeTile({
    required this.bedtime,
    required this.onChanged,
    this.label = 'Bedtime',
  });

  final TimeOfDay bedtime;
  final ValueChanged<TimeOfDay> onChanged;
  final String label;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: bedtime,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: TextButton(
        onPressed: () => _pick(context),
        child: Text(
          bedtime.format(context),
          style: const TextStyle(
            color: Color(0xFF00D4FF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DisabledWrapper extends StatelessWidget {
  const _DisabledWrapper({required this.disabled, required this.child});
  final bool disabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: child,
      ),
    );
  }
}

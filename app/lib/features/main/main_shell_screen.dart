import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_nav_notifier.dart';
import '../../l10n/generated/app_localizations.dart';
import '../analytics/analytics_screen.dart';
import '../coach/screens/coach_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../meal/screens/meal_scan_screen.dart';
import '../profile/goals_profile_screen.dart';
import '../settings/settings_screen.dart';

/// The persistent shell that hosts the three primary tabs of the app.
///
/// Replaces what used to be a single ``DashboardScreen`` returning its own
/// ``_BottomNavPlaceholder`` from Chat 13. The placeholder bottom nav
/// surfaced "X is wired up in Chat 17 (Navigation)" toasts on every tap,
/// which Apple/Play review would treat as broken navigation.
///
/// IndexedStack keeps each tab's state (scroll position, async data,
/// form input) alive when the user swaps tabs — far better than the
/// rebuild-each-tap that a plain ``switch`` returns.
///
/// Tab 0 → Dashboard (existing 6-widget read-only summary)
/// Tab 1 → Profile  (existing 352-line goals_profile_screen)
/// Tab 2 → Settings (existing — export, delete, sign out, notification prefs)
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Listen for notification-tap tab requests. The notifier is a singleton
    // so this subscription is safe across hot restarts.
    NotificationNavNotifier.instance.tabIndex.addListener(_onNotificationNav);
  }

  @override
  void dispose() {
    NotificationNavNotifier.instance.tabIndex
        .removeListener(_onNotificationNav);
    super.dispose();
  }

  void _onNotificationNav() {
    final tab = NotificationNavNotifier.instance.tabIndex.value;
    if (tab != null && mounted) {
      setState(() => _index = tab);
      NotificationNavNotifier.instance.consume();
    }
  }

  static const _icons = <IconData>[
    Icons.dashboard_rounded,
    Icons.camera_alt_outlined,
    Icons.auto_awesome_rounded,
    Icons.insights_outlined,
    Icons.person_outline,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = <String>[
      l10n?.navDashboard ?? 'Dashboard',
      l10n?.navScan ?? 'Scan',
      l10n?.navCoach ?? 'Coach',
      l10n?.navAnalytics ?? 'Analytics',
      l10n?.navProfile ?? 'Profile',
      l10n?.navSettings ?? 'Settings',
    ];
    final tabs = <_TabSpec>[
      for (var i = 0; i < _icons.length; i++)
        _TabSpec(icon: _icons[i], label: labels[i]),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          MealScanScreen(),
          CoachScreen(),
          AnalyticsScreen(),
          GoalsProfileScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _NuveliBottomNav(
        index: _index,
        tabs: tabs,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _TabSpec {
  final IconData icon;
  final String label;
  const _TabSpec({required this.icon, required this.label});
}

class _NuveliBottomNav extends StatelessWidget {
  final int index;
  final List<_TabSpec> tabs;
  final ValueChanged<int> onTap;

  const _NuveliBottomNav({
    required this.index,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050A1F).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final spec = tabs[i];
              final active = i == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          spec.icon,
                          color: active
                              ? const Color(0xFF4DDBFF)
                              : const Color(0xFF6E7B91),
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spec.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w500,
                            color: active
                                ? const Color(0xFF4DDBFF)
                                : const Color(0xFF6E7B91),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

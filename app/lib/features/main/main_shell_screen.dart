import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/dashboard_screen.dart';
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

  static const _tabs = <_TabSpec>[
    _TabSpec(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _TabSpec(icon: Icons.person_outline, label: 'Profile'),
    _TabSpec(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          GoalsProfileScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _NuveliBottomNav(
        index: _index,
        tabs: _tabs,
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

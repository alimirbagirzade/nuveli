import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/habits_provider.dart';
import 'widgets/habits_header.dart';
import 'widgets/motivational_footer.dart';
import 'widgets/streak_banner.dart';
import 'widgets/todays_habits_section.dart';
import 'widgets/upcoming_reminders_section.dart';
import 'widgets/weekly_consistency_section.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _secondaryText = Color(0xFFB8C5D6);
const Color _danger = Color(0xFFFF5C5C);

/// Healthy Habits screen — Görsel 7.
///
/// Same pattern as `MealPlannerScreen` (Chat 9): `DecoratedBox` with the
/// underwater gradient as background, `Scaffold` with transparent
/// background, `SafeArea` + `CustomScrollView`, inline bottom nav.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(habitsProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050A1F), Color(0xFF0B1A3D)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: asyncData.when(
            loading: () => const _HabitsSkeleton(),
            error: (e, _) => _HabitsError(
              message: e.toString(),
              onRetry: () => ref.read(habitsProvider.notifier).refresh(),
            ),
            data: (data) => RefreshIndicator(
              onRefresh: () => ref.read(habitsProvider.notifier).refresh(),
              color: _cyan,
              backgroundColor: const Color(0xFF102B3F),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: HabitsHeader(
                      onBack: () => Navigator.of(context).maybePop(),
                      onSettings: () {
                        // Settings nav wired in Chat 12 (routing).
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 4),
                        StreakBanner(
                          streakDays: data.streakDays,
                          habitsCompleted: data.completedToday,
                          habitsTotal: data.totalHabits,
                        ),
                        const SizedBox(height: 20),
                        TodaysHabitsSection(
                          habits: data.todaysHabits,
                          onToggle: (id, v) => ref
                              .read(habitsProvider.notifier)
                              .toggleHabit(id, v),
                        ),
                        const SizedBox(height: 20),
                        WeeklyConsistencySection(
                          data: data.weeklyConsistency,
                        ),
                        const SizedBox(height: 20),
                        UpcomingRemindersSection(
                          reminders: data.upcomingReminders,
                          onToggle: (id, v) => ref
                              .read(habitsProvider.notifier)
                              .toggleReminder(id, v),
                        ),
                        const SizedBox(height: 12),
                        const MotivationalFooter(),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const _HabitsBottomNav(),
      ),
    );
  }
}

/// Inline bottom nav matching the mockup. Dashboard tab visually selected
/// (cyan). Tapping is a no-op until Chat 12 (routing) wires it up.
class _HabitsBottomNav extends StatelessWidget {
  const _HabitsBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF050A1F),
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: const [
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Dashboard',
                selected: true,
              ),
              _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Meals',
              ),
              _NavItem(
                icon: Icons.show_chart_rounded,
                label: 'Analytics',
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
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

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _cyan : _secondaryText;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading / Error ────────────────────────────────────────────────────────

class _HabitsSkeleton extends StatelessWidget {
  const _HabitsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: _cyan,
        strokeWidth: 2.5,
      ),
    );
  }
}

class _HabitsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HabitsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: _danger,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load your habits",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
                style: TextStyle(color: _cyan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

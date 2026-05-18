import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_bottom_nav.dart';
import 'providers/habits_provider.dart';
import 'widgets/habits_header.dart';
import 'widgets/motivational_footer.dart';
import 'widgets/streak_banner.dart';
import 'widgets/todays_habits_section.dart';
import 'widgets/upcoming_reminders_section.dart';
import 'widgets/weekly_consistency_section.dart';

/// Healthy Habits screen — Görsel 7.
///
/// Sections (top → bottom):
///   1. HabitsHeader        — back + title + settings
///   2. StreakBanner        — 18 day streak + progress bar
///   3. TodaysHabitsSection — 5 habit check tiles
///   4. WeeklyConsistencySection — 7-pill bar chart (Sat highlighted)
///   5. UpcomingRemindersSection — 2 reminder toggles
///   6. MotivationalFooter  — ⭐ encouragement card
///   7. NuveliBottomNav     — Dashboard tab active (currentIndex = 0)
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: habitsAsync.when(
            loading: () => const _HabitsSkeleton(),
            error: (e, st) => _HabitsError(
              message: e.toString(),
              onRetry: () => ref.read(habitsProvider.notifier).refresh(),
            ),
            data: (data) => RefreshIndicator(
              onRefresh: () => ref.read(habitsProvider.notifier).refresh(),
              color: AppColors.primaryCyan,
              backgroundColor: AppColors.cardBackground,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: HabitsHeader(
                      onBack: () => Navigator.maybePop(context),
                      onSettings: () {/* stub — wired in Chat 12 */},
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        StreakBanner(
                          streakDays: data.streakDays,
                          habitsCompleted: data.completedToday,
                          habitsTotal: data.totalHabits,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TodaysHabitsSection(
                          habits: data.todaysHabits,
                          onToggle: (id, v) => ref
                              .read(habitsProvider.notifier)
                              .toggleHabit(id, v),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        WeeklyConsistencySection(
                          data: data.weeklyConsistency,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        UpcomingRemindersSection(
                          reminders: data.upcomingReminders,
                          onToggle: (id, v) => ref
                              .read(habitsProvider.notifier)
                              .toggleReminder(id, v),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const MotivationalFooter(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NuveliBottomNav(
          currentIndex: 0,
          onTap: (i) {/* stub — wired in Chat 12 */},
        ),
      ),
    );
  }
}

/// Lightweight skeleton shown while the provider's initial fetch resolves.
class _HabitsSkeleton extends StatelessWidget {
  const _HabitsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryCyan,
        strokeWidth: 2.5,
      ),
    );
  }
}

/// Error fallback with a retry button.
class _HabitsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HabitsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Couldn't load your habits",
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
                style: TextStyle(color: AppColors.primaryCyan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

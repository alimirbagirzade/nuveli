import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_bottom_nav.dart';
import 'providers/profile_provider.dart';
import 'widgets/daily_calorie_target_card.dart';
import 'widgets/goals_row.dart';
import 'widgets/profile_header.dart';
import 'widgets/progress_section.dart';
import 'widgets/recommendations_section.dart';

/// Goals & Profile screen — replicates Görsel 3 of the App Store mockups.
///
/// Sections (top → bottom):
///   1. ProfileHeader (logo + "Your Goals" + settings)
///   2. DailyCalorieTargetCard (target + mini progress donut)
///   3. GoalsRow (Weight goal + Daily streak)
///   4. ProgressSection ("Calories vs Target" weekly bar chart)
///   5. RecommendationsSection (personalized tip cards)
///   6. NuveliBottomNav (Profile tab selected)
class GoalsOverviewScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: profileAsync.when(
            loading: () => const _GoalsOverviewSkeleton(),
            error: (e, st) => _GoalsOverviewError(
              onRetry: () => ref.invalidate(profileProvider),
            ),
            data: (data) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(profileProvider);
                await ref.read(profileProvider.future);
              },
              color: AppColors.primaryCyan,
              backgroundColor: AppColors.cardBackground,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      onSettingsTap: () {
                        // Stub: settings screen comes in a later chat.
                        debugPrint('Settings tapped');
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, // 16
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        DailyCalorieTargetCard(
                          target: data.dailyCalorieTarget,
                          progressPercent: data.todayProgressPercent,
                        ),
                        const SizedBox(height: AppSpacing.sm + 4), // 12
                        GoalsRow(
                          weightGoal: data.weightGoal,
                          streakDays: data.streakDays,
                        ),
                        const SizedBox(height: AppSpacing.lg + 4), // 24
                        ProgressSection(weeklyData: data.weeklyCalories),
                        const SizedBox(height: AppSpacing.lg + 4), // 24
                        RecommendationsSection(
                          recommendations: data.recommendations,
                        ),
                        const SizedBox(height: 100), // bottom-nav clearance
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NuveliBottomNav(
          currentIndex: 3, // Profile tab
          onTap: (i) {
            // Stub: real routing arrives in Chat 12.
            debugPrint('Bottom nav tapped: $i');
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Loading & error states
// ──────────────────────────────────────────────────────────────────────────────

class _GoalsOverviewSkeleton extends StatelessWidget {
  const _GoalsOverviewSkeleton();

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

class _GoalsOverviewError extends StatelessWidget {
  final VoidCallback onRetry;

  const _GoalsOverviewError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.secondaryText,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            Text(
              "Couldn't load your goals.",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryCyan,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

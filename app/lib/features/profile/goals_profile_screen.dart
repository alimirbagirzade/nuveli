import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';

import 'models/user_profile.dart';
import 'models/weekly_analytics.dart';
import 'providers/profile_provider.dart';
import 'widgets/daily_calorie_target_card.dart';
import 'widgets/goals_row.dart';
import 'widgets/profile_header.dart';
import 'widgets/progress_section.dart';
import 'widgets/recommendations_section.dart';
import 'widgets/set_weight_goal_sheet.dart';
import 'widgets/weight_goal_card.dart';
import 'widgets/weight_log_sheet.dart';

/// "Your Goals" screen — Görsel 3 of the App Store mockups.
///
/// Composition (top → bottom):
///   1. ProfileHeader              ← profileProvider
///   2. DailyCalorieTargetCard     ← profileProvider + todaySummaryProvider
///   3. GoalsRow:
///        • WeightGoalCard         ← weightGoalProvider + weightTrendProvider
///        • StreakDisplayCard      ← streakProvider
///   4. ProgressSection            ← weeklyAnalyticsProvider
///   5. RecommendationsSection     ← static (AI hook lands in Chat 11)
///
/// Floating Action Button: opens the weight-log sheet.
class GoalsProfileScreen extends ConsumerWidget {
  const GoalsProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050A1F),
              Color(0xFF0B1A3D),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primaryCyan,
            backgroundColor: const Color(0xFF0B1A3D),
            onRefresh: () => refreshAllProfileData(ref),
            child: profileAsync.when(
              loading: () => const _FullScreenSkeleton(),
              error: (e, _) => _FullScreenError(
                error: e,
                onRetry: () => ref.invalidate(profileProvider),
              ),
              data: (profile) => _LoadedView(profile: profile),
            ),
          ),
        ),
      ),
      floatingActionButton: profileAsync.maybeWhen(
        data: (p) => _LogWeightFab(currentKg: p.weightKg),
        orElse: () => null,
      ),
    );
  }
}

class _LoadedView extends ConsumerWidget {
  final UserProfile profile;
  const _LoadedView({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todaySummaryProvider);
    final goalAsync = ref.watch(weightGoalProvider);
    final trendAsync = ref.watch(weightTrendProvider);
    final streakAsync = ref.watch(streakProvider);
    final weeklyAsync = ref.watch(weeklyAnalyticsProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ProfileHeader(profile: profile),
        ),
        SliverToBoxAdapter(
          child: todayAsync.when(
            loading: () => const _CardSkeleton(height: 140),
            error: (_, __) => _InlineError(
              onRetry: () => ref.invalidate(dashboardSummaryProvider),
            ),
            data: (today) => DailyCalorieTargetCard(
              profile: profile,
              todaySummary: today,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
        SliverToBoxAdapter(
          child: GoalsRow(
            leftCard: goalAsync.when(
              loading: () => const _SmallSkeleton(),
              error: (_, __) => _InlineError(
                onRetry: () => ref.invalidate(weightGoalProvider),
              ),
              data: (goal) {
                if (goal == null) {
                  return SetWeightGoalCard(
                    onTap: () async {
                      final saved = await showSetWeightGoalSheet(
                        context,
                        currentWeightKg: profile.weightKg,
                      );
                      if (saved == true) {
                        ref.invalidate(weightGoalProvider);
                      }
                    },
                  );
                }
                final trend = trendAsync.maybeWhen(
                  data: (t) => t,
                  orElse: () => null,
                );
                return WeightGoalCard(
                  goal: goal,
                  trend: trend,
                  onTap: () async {
                    final saved = await showSetWeightGoalSheet(
                      context,
                      currentWeightKg: profile.weightKg,
                    );
                    if (saved == true) ref.invalidate(weightGoalProvider);
                  },
                );
              },
            ),
            rightCard: streakAsync.when(
              loading: () => const _SmallSkeleton(),
              error: (_, __) => _InlineError(
                onRetry: () => ref.invalidate(dashboardSummaryProvider),
              ),
              data: (streak) => StreakDisplayCard(streakDays: streak),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s24)),
        SliverToBoxAdapter(
          child: weeklyAsync.when(
            loading: () => const _CardSkeleton(height: 220),
            error: (_, __) => _InlineError(
              onRetry: () => ref.invalidate(weeklyAnalyticsProvider),
            ),
            data: (a) => ProgressSection(analytics: a),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s24)),
        const SliverToBoxAdapter(child: RecommendationsSection()),
        // Bottom padding so FAB doesn't overlap last card.
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _LogWeightFab extends ConsumerWidget {
  final double? currentKg;
  const _LogWeightFab({required this.currentKg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      backgroundColor: AppColors.primaryCyan,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Log weight',
        style: AppTypography.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () async {
        final saved = await showWeightLogSheet(
          context,
          initialKg: currentKg,
        );
        if (saved == true) {
          // weightTrendProvider + profileProvider + weightGoalProvider already
          // invalidated by ProfileActions; nothing to do here.
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING / ERROR PRIMITIVES
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenSkeleton extends StatelessWidget {
  const _FullScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s24,
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _SkeletonBox(height: 56, width: 220),
        SizedBox(height: AppSpacing.s24),
        _SkeletonBox(height: 140),
        SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 160)),
            SizedBox(width: AppSpacing.s12),
            Expanded(child: _SkeletonBox(height: 160)),
          ],
        ),
        SizedBox(height: AppSpacing.s24),
        _SkeletonBox(height: 220),
      ],
    );
  }
}

class _FullScreenError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _FullScreenError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withValues(alpha: 0.15),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Couldn\'t load your profile',
              style: AppTypography.cardTitle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                  vertical: AppSpacing.s12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final VoidCallback onRetry;
  const _InlineError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              'Couldn\'t load this section',
              style: AppTypography.body.copyWith(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTypography.body.copyWith(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final double height;
  const _CardSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: _SkeletonBox(height: height),
    );
  }
}

class _SmallSkeleton extends StatelessWidget {
  const _SmallSkeleton();
  @override
  Widget build(BuildContext context) => const _SkeletonBox(height: 160);
}

class _SkeletonBox extends StatefulWidget {
  final double height;
  final double? width;
  const _SkeletonBox({required this.height, this.width});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
            color: Colors.white.withValues(
              alpha: 0.04 + (_ctrl.value * 0.04),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        );
      },
    );
  }
}

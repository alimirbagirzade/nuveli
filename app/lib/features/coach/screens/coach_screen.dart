import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../premium/premium_paywall_screen.dart';
import '../models/ai_insight.dart';
import '../providers/coach_actions_controller.dart';
import '../providers/coach_provider.dart';
import '../widgets/nutrition_score_meter.dart';
import '../widgets/recommended_action_button.dart';
import '../widgets/tip_tile.dart';

/// F2 v0 — Coach tab. Insight-only surface: today's nutrition score,
/// the coaching paragraph, tips, and (if present) a one-tap apply-tip
/// CTA. Pull-to-refresh re-fetches the cached insight; the Regenerate
/// button calls `/coach/generate` (1/day free, premium unlimited).
class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(coachTodayProvider);
    final gate = ref.watch(coachGateProvider);
    final actionState = ref.watch(coachActionsControllerProvider);
    final isRegenerating =
        actionState.phase == CoachActionPhase.regenerating;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.coachSettingsTitle ?? 'Your Coach',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(coachTodayProvider);
            await ref.read(coachTodayProvider.future);
          },
          child: insightAsync.when(
            loading: () => const _CoachLoading(),
            error: (e, _) => _CoachError(
              message: e.toString(),
              onRetry: () => ref.invalidate(coachTodayProvider),
            ),
            data: (insight) => _CoachContent(
              insight: insight,
              isRegenerating: isRegenerating,
              regenLabel: _regenLabel(l10n, gate),
              canRegenerate: gate.canRegenerate,
              onRegenerate: () async {
                if (!gate.canRegenerate) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumPaywallScreen(
                          source: 'ai_coach'),
                    ),
                  );
                  return;
                }
                await ref
                    .read(coachActionsControllerProvider.notifier)
                    .regenerate();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Localized regenerate-CTA label, mirroring CoachGateStatus.ctaLabel.
  static String _regenLabel(AppLocalizations? l10n, CoachGateStatus gate) {
    if (l10n == null) return gate.ctaLabel;
    if (gate.isPremium) return l10n.coachRegenerate;
    if (!gate.canRegenerate) return l10n.coachRegenerateUpgrade;
    return l10n.coachRegenerateFree;
  }
}

class _CoachContent extends StatelessWidget {
  const _CoachContent({
    required this.insight,
    required this.isRegenerating,
    required this.regenLabel,
    required this.canRegenerate,
    required this.onRegenerate,
  });

  final AIInsight insight;
  final bool isRegenerating;
  final String regenLabel;
  final bool canRegenerate;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // A brand-new user (no meals logged) gets a placeholder insight row from
    // the backend: score 0, empty paragraph/tips, no model run. Showing the
    // red "0 / needs care / pick a tip below" score card there is both
    // demotivating and a dead-end (there are no tips below). Detect that
    // state and show a friendly "log your first meal" empty state instead.
    final isEmptyInsight = insight.todayInsight.isEmpty &&
        insight.tips.isEmpty &&
        insight.recommendedAction == null &&
        insight.modelUsed == null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (isEmptyInsight) ...[
          _CoachEmpty(l10n: l10n),
          const SizedBox(height: 16),
        ] else ...[
          _ScoreCard(insight: insight),
          const SizedBox(height: 16),
          if (insight.todayInsight.isNotEmpty) ...[
            _InsightBody(text: insight.todayInsight),
            const SizedBox(height: 16),
          ],
          if (insight.tips.isNotEmpty) ...[
            _SectionLabel(l10n?.coachTodaysTips ?? "Today's tips"),
            const SizedBox(height: 8),
            for (final tip in insight.tips) TipTile(tip: tip),
            const SizedBox(height: 6),
          ],
          if (insight.recommendedAction != null && insight.id != null) ...[
            RecommendedActionButton(
              insightId: insight.id!,
              action: insight.recommendedAction!,
            ),
            const SizedBox(height: 16),
          ],
        ],
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: isRegenerating ? null : onRegenerate,
            icon: isRegenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : Icon(
                    canRegenerate
                        ? Icons.refresh_rounded
                        : Icons.workspace_premium_rounded,
                    color: Colors.white,
                  ),
            label: Text(
              regenLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.insight});
  final AIInsight insight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          NutritionScoreMeter(score: insight.nutritionScore),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.coachNutritionScore ?? 'Nutrition score',
                  style: const TextStyle(
                    color: Color(0xFFB8D4D2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateLabel(l10n, insight.insightDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(l10n, insight.nutritionScore),
                  style: const TextStyle(
                    color: Color(0xFFB8D4D2),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dateLabel(AppLocalizations? l10n, DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return l10n?.homeToday ?? 'Today';
    }
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _subtitle(AppLocalizations? l10n, int score) {
    if (score >= 80) {
      return l10n?.coachScoreHigh ?? "Solid day — keep doing what you're doing.";
    }
    if (score >= 60) {
      return l10n?.coachScoreMid ??
          'Mostly on track. A small tweak goes a long way.';
    }
    if (score >= 40) {
      return l10n?.coachScoreMixed ??
          "Mixed signals — let's focus on one thing today.";
    }
    return l10n?.coachScoreReset ??
        'A gentle reset would help. Pick one tip below.';
  }
}

class _InsightBody extends StatelessWidget {
  const _InsightBody({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE8F3F1),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Empty state for a fresh user with no logged meals yet — replaces the
/// red "0 / needs care / pick a tip below" score card, which blamed the
/// user for an absence of data and pointed at tips that weren't there.
class _CoachEmpty extends StatelessWidget {
  const _CoachEmpty({required this.l10n});
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n?.coachEmptyTitle ?? 'Your coach is getting ready',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.coachEmptyBody ??
                'Log your first meal today and your coach will prepare '
                    'daily insights and tips just for you.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB8D4D2),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachLoading extends StatelessWidget {
  const _CoachLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: const [
        _SkeletonBlock(height: 160, radius: 18),
        SizedBox(height: 16),
        _SkeletonBlock(height: 96, radius: 14),
        SizedBox(height: 16),
        _SkeletonBlock(height: 64, radius: 14),
        SizedBox(height: 10),
        _SkeletonBlock(height: 64, radius: 14),
        SizedBox(height: 10),
        _SkeletonBlock(height: 64, radius: 14),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.radius});
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _CoachError extends StatelessWidget {
  const _CoachError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.coachOfflineTitle ?? 'Coach is offline',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                l10n?.commonRetry ?? 'Try again',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

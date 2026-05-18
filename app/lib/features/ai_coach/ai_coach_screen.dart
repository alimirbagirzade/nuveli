import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/ai_coach_provider.dart';
import 'widgets/coach_header.dart';
import 'widgets/daily_recap_card.dart';
import 'widgets/insights_grid.dart';
import 'widgets/nutrition_score_ring.dart';
import 'widgets/recommended_for_you_card.dart';
import 'widgets/todays_insight_card.dart';
import 'widgets/todays_summary_mini.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _secondaryText = Color(0xFFB8C5D6);
const Color _danger = Color(0xFFFF5C5C);

/// AI Coach Insights screen — Görsel 8.
///
/// Same composition pattern as `HabitsScreen` (Chat 10): `DecoratedBox` with
/// the underwater gradient as background, `Scaffold` with transparent
/// background, `SafeArea` + `CustomScrollView`, inline bottom nav.
class AICoachScreen extends ConsumerWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(aiCoachProvider);

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
            loading: () => const _CoachSkeleton(),
            error: (e, _) => _CoachError(
              message: e.toString(),
              onRetry: () => ref.read(aiCoachProvider.notifier).refresh(),
            ),
            data: (data) => RefreshIndicator(
              onRefresh: () => ref.read(aiCoachProvider.notifier).refresh(),
              color: _cyan,
              backgroundColor: const Color(0xFF102B3F),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: CoachHeader(
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
                        const SizedBox(height: 8),
                        NutritionScoreRing(
                          score: data.nutritionScore.value,
                          label: data.nutritionScore.label,
                        ),
                        const SizedBox(height: 28),
                        TodaysInsightCard(insight: data.mainInsight),
                        const SizedBox(height: 16),
                        InsightsGrid(insights: data.smallInsights),
                        const SizedBox(height: 28),
                        TodaysSummaryMini(macros: data.todaysMacros),
                        const SizedBox(height: 28),
                        RecommendedForYouCard(
                          recommendation: data.recommendation,
                          onApply: () => ref
                              .read(aiCoachProvider.notifier)
                              .applyTip(),
                          onSeeDetails: () {
                            // TODO: open details bottom sheet
                          },
                        ),
                        const SizedBox(height: 16),
                        DailyRecapCard(recap: data.dailyRecap),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const _CoachBottomNav(),
      ),
    );
  }
}

/// Inline bottom nav matching the mockup. Profile tab visually selected
/// because AI Coach is reached from Profile. Tapping is a no-op until
/// Chat 12 (routing) wires it up.
class _CoachBottomNav extends StatelessWidget {
  const _CoachBottomNav();

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
                selected: true,
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

class _CoachSkeleton extends StatelessWidget {
  const _CoachSkeleton();

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

class _CoachError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CoachError({required this.message, required this.onRetry});

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
              "Couldn't load today's coaching",
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

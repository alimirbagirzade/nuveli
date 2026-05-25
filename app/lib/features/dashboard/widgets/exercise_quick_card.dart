import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../exercise/models/exercise_summary.dart';
import '../../exercise/providers/exercise_provider.dart';
import '../../exercise/widgets/log_exercise_sheet.dart';

/// Compact activity tracker row on the dashboard.
///
/// Shows today's total active minutes + a celebratory line + sessions
/// count, and opens the log-activity sheet on tap. Mirrors the visual
/// style of `WaterQuickCard`.
///
/// Wellness boundary: this surfaces minutes + sessions ONLY. There is
/// deliberately no "calories burned" and no implication that activity
/// changes the calorie budget. Copy is positive and neutral.
class ExerciseQuickCard extends ConsumerWidget {
  const ExerciseQuickCard({super.key});

  // Mint-green "movement" accent (distinct from water's cyan).
  static const Color _accent = Color(0xFF4ADE80);
  static const Color _accentSoft = Color(0xFF86EFAC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(exerciseTodaySummaryProvider);

    // Fall back to an empty summary on load/error so the card stays
    // tappable (logging the first activity is the whole point) and never
    // blocks the dashboard.
    final summary = summaryAsync.valueOrNull ?? const ExerciseSummary.empty();

    return InkWell(
      onTap: () => LogExerciseSheet.show(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF142346).withValues(alpha: 0.5),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Activity icon
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _accent.withValues(alpha: 0.25),
                    _accentSoft.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: _accentSoft,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n?.exercise ?? 'Activity',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB8C5D6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (summary.sessionsCount > 0)
                        Text(
                          l10n?.exerciseSessionsCount(summary.sessionsCount) ??
                              '${summary.sessionsCount} sessions',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6E7B91),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.active
                        ? (l10n?.exerciseTodayActive(summary.totalMinutes) ??
                            'You were active for ${summary.totalMinutes} min today 💪')
                        : (l10n?.exerciseNoneToday ??
                            'How about a little movement today?'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (summary.active) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n?.exerciseGreatMoving ?? 'Moving feels great!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _accentSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Add-activity button
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [_accent, _accentSoft],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Color(0xFF05291A), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

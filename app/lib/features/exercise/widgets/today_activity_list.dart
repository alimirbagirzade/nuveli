import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/exercise_log.dart';
import '../providers/exercise_provider.dart';
import 'calorie_badge.dart';
import 'log_exercise_sheet.dart';

// Shared palette with the log sheet / quick card.
const Color _kAccentSoft = Color(0xFF86EFAC);
const Color _kMuted = Color(0xFFB8C5D6);
const Color _kFaint = Color(0xFF6E7B91);

/// Renders today's logged activities as a compact, deletable list.
///
/// Each row: activity icon + localized name, duration, optional intensity,
/// and (only when present) the informational "≈ kcal" badge. Swipe a row to
/// delete it; `deleteExerciseProvider` refreshes the summary/list/weekly.
///
/// Wellness boundary: the calorie badge here is display-only and never tied to
/// the calorie budget — see [CalorieBadge].
class TodayActivityList extends ConsumerWidget {
  /// When true (sheet context) the section header is shown.
  final bool showHeader;

  /// Cap rows shown; null = show all.
  final int? maxItems;

  const TodayActivityList({super.key, this.showHeader = true, this.maxItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logsAsync = ref.watch(todayExerciseLogsProvider);

    final logs = logsAsync.valueOrNull ?? const <ExerciseLog>[];
    if (logs.isEmpty) return const SizedBox.shrink();

    final shown =
        (maxItems != null && logs.length > maxItems!) ? logs.take(maxItems!) : logs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          Text(
            l10n?.exerciseTodayActivities ?? 'Today',
            style: const TextStyle(
              color: _kMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...shown.map((log) => _ActivityRow(log: log)),
      ],
    );
  }
}

class _ActivityRow extends ConsumerWidget {
  final ExerciseLog log;
  const _ActivityRow({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = exerciseTypeLabel(l10n, log.activityType);
    final duration =
        l10n?.exerciseDurationLabel(log.durationMin) ?? '${log.durationMin} min';
    final intensity = log.intensity != null
        ? exerciseIntensityLabel(l10n, log.intensity!)
        : null;

    return Dismissible(
      key: ValueKey(log.id),
      direction: DismissDirection.endToStart,
      background: _deleteBackground(),
      confirmDismiss: (_) async {
        final id = log.id;
        if (id.isEmpty) return false;
        try {
          await ref.read(deleteExerciseProvider)(id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.exerciseDeleted ?? 'Activity removed',
                ),
              ),
            );
          }
          return true;
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.exerciseDeleteFailed ??
                      'Could not remove that activity. Try again.',
                ),
              ),
            );
          }
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(exerciseTypeIcon(log.activityType),
                size: 18, color: _kAccentSoft),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Small glyph marking entries pulled from the phone's
                      // health store (Health Connect / Apple Health). Manual
                      // entries show nothing — they're the unmarked default.
                      if (log.isImported) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.phone_iphone_rounded,
                          size: 13,
                          color: _kFaint,
                          semanticLabel:
                              l10n?.exerciseSourceHealth ?? 'From health app',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    intensity == null ? duration : '$duration · $intensity',
                    style: const TextStyle(color: _kFaint, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Informational calorie estimate — only when the backend
            // returned one. No placeholder when null.
            if (log.estCalories != null) ...[
              const SizedBox(width: 8),
              CalorieBadge(kcal: log.estCalories!),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: _kFaint.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFF5C5C).withValues(alpha: 0.18),
      ),
      child: const Icon(Icons.delete_outline_rounded,
          color: Color(0xFFFF8A8A), size: 20),
    );
  }
}

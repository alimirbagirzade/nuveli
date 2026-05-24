import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/ai_insight.dart';
import '../providers/coach_actions_controller.dart';

/// Renders the `recommended_action` block beneath the insight.
/// - Always shows the explanatory text.
/// - If `action_type` is set, shows an "Apply" CTA that calls
///   POST /coach/apply-tip.
class RecommendedActionButton extends ConsumerWidget {
  const RecommendedActionButton({
    super.key,
    required this.insightId,
    required this.action,
  });

  final String insightId;
  final RecommendedAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(coachActionsControllerProvider).phase;
    final isApplying = phase == CoachActionPhase.applyingTip;
    final l10n = AppLocalizations.of(context);

    ref.listen<CoachActionState>(coachActionsControllerProvider, (prev, next) {
      if (prev?.lastAppliedAction != next.lastAppliedAction &&
          next.lastAppliedAction != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              content: Text(
                _confirmationFor(l10n, next.lastAppliedAction!),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
      }
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                l10n?.coachRecommendedStep ?? 'Recommended next step',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            action.text,
            style: const TextStyle(
              color: Color(0xFFE8F3F1),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          if (action.isExecutable) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: isApplying
                    ? null
                    : () => ref
                        .read(coachActionsControllerProvider.notifier)
                        .applyRecommendedTip(insightId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isApplying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _actionCtaLabel(l10n, action.actionType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _actionCtaLabel(AppLocalizations? l10n, String? actionType) {
    switch (actionType) {
      case 'add_meal':
        return l10n?.coachActionAddMeal ?? 'Add meal';
      case 'adjust_reminder':
        return l10n?.coachActionSetReminder ?? 'Set reminder';
      case 'add_habit':
        return l10n?.coachActionAddHabit ?? 'Add habit';
      case 'log_water':
        return l10n?.coachActionLogWater ?? 'Log water';
      case 'increase_target':
        return l10n?.coachActionUpdateTarget ?? 'Update target';
      default:
        return l10n?.coachActionApply ?? 'Apply';
    }
  }

  static String _confirmationFor(AppLocalizations? l10n, String actionTaken) {
    switch (actionTaken) {
      case 'add_habit':
        return l10n?.coachActionHabitAdded ?? 'Habit added';
      case 'log_water':
        return l10n?.coachActionWaterLogged ?? 'Water logged';
      case 'adjust_reminder':
        return l10n?.coachActionReminderSet ?? 'Reminder set';
      case 'increase_target':
        return l10n?.coachActionTargetUpdated ?? 'Target updated';
      default:
        return l10n?.coachActionDone ?? 'Done';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coach/mood/providers/mood_bubble_controller.dart';
import '../../coach/mood/widgets/mood_bubble.dart';
import '../../profile/providers/profile_provider.dart'
    show dashboardSummaryProvider;
import '../providers/meal_scan_controller.dart';
import '../providers/scan_count_provider.dart';
import '../widgets/scan_error_view.dart';
import '../widgets/scan_idle_view.dart';
import '../widgets/scan_loading_view.dart';
import '../widgets/scan_not_food_view.dart';
import '../widgets/scan_preview_view.dart';
import '../widgets/scan_result_view.dart';

/// F1 — AI Meal Scan tab body. Lives inside `MainShellScreen`'s
/// IndexedStack so its state survives tab switches.
///
/// Phase switch:
///   idle          → ScanIdleView   (CTA + counter)
///   previewing    → ScanPreviewView (image preview + retake / scan)
///   analyzing     → ScanLoadingView (rotating progress text)
///   resultEditing → ScanResultView  (editable foods + scale + save)
///   notFood       → ScanNotFoodView (explanation + retake / manual)
///   error         → ScanErrorView   (retry / manual)
///   saving        → ScanLoadingView (with "Saving meal...")
///   saved         → snackbar + reset to idle (handled by listener)
class MealScanScreen extends ConsumerStatefulWidget {
  const MealScanScreen({super.key});

  @override
  ConsumerState<MealScanScreen> createState() => _MealScanScreenState();
}

class _MealScanScreenState extends ConsumerState<MealScanScreen> {
  @override
  Widget build(BuildContext context) {
    // On save: fire a persona mood bubble (replaces the old generic
    // "Meal logged" snackbar), then reset to idle so the screen is fresh
    // next time the tab is opened.
    ref.listen<MealScanState>(mealScanControllerProvider, (prev, next) {
      if (prev?.phase != MealScanPhase.saved &&
          next.phase == MealScanPhase.saved) {
        _showMealMoodBubble();
        Future.microtask(() {
          if (!mounted) return;
          ref.read(mealScanControllerProvider.notifier).reset();
        });
      }
    });

    final state = ref.watch(mealScanControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI Meal Scan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  /// Awaits the freshly-invalidated dashboard summary (the save flow
  /// already invalidated `dashboardSummaryProvider`), then shows a mood
  /// bubble whose situation reflects today's *post-save* totals. The
  /// bubble is cosmetic, so any failure is swallowed silently.
  Future<void> _showMealMoodBubble() async {
    try {
      final summary = await ref.read(dashboardSummaryProvider.future);
      if (!mounted) return;
      final today = summary.todaySummary;
      final situation = MoodBubbleLogic.mealSituation(
        caloriesConsumed: today.caloriesConsumed,
        caloriesTarget: today.caloriesTarget,
        // mealsLogged already includes the meal just saved.
        mealsLoggedBefore: today.mealsLogged - 1,
      );
      showMoodBubble(context, ref, situation);
    } catch (_) {
      // Network/parse failure: skip the bubble rather than block the flow.
    }
  }

  Widget _buildBody(MealScanState state) {
    switch (state.phase) {
      case MealScanPhase.idle:
      case MealScanPhase.saved:
        return const ScanIdleView();
      case MealScanPhase.previewing:
        return ScanPreviewView(imagePath: state.imagePath!);
      case MealScanPhase.analyzing:
        return const ScanLoadingView(mode: ScanLoadingMode.analyzing);
      case MealScanPhase.saving:
        return const ScanLoadingView(mode: ScanLoadingMode.saving);
      case MealScanPhase.notFood:
        return ScanNotFoodView(explanation: state.scanResult?.portionInsight.mainText);
      case MealScanPhase.resultEditing:
        return const ScanResultView();
      case MealScanPhase.error:
        return ScanErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          isRateLimited: state.isRateLimited,
        );
    }
  }
}

/// Read-only helper used by widgets that need the gate snapshot.
/// Kept here so screens/widgets don't import each other.
AsyncValue<ScanGateStatus> readGate(WidgetRef ref) =>
    ref.watch(scanGateProvider);

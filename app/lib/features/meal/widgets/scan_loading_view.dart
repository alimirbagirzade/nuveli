import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

enum ScanLoadingMode { analyzing, saving }

/// Spinner + rotating progress text. OpenAI Vision takes 6–15s; the
/// rotating copy signals progress and keeps the screen feeling alive.
class ScanLoadingView extends StatefulWidget {
  const ScanLoadingView({super.key, this.mode = ScanLoadingMode.analyzing});
  final ScanLoadingMode mode;

  @override
  State<ScanLoadingView> createState() => _ScanLoadingViewState();
}

class _ScanLoadingViewState extends State<ScanLoadingView> {
  int _index = 0;
  Timer? _timer;

  List<String> _analyzingSteps(AppLocalizations? l10n) => [
        l10n?.mealScanAnalyzingStep1 ?? 'Analyzing your meal...',
        l10n?.mealScanAnalyzingStep2 ?? 'Identifying foods...',
        l10n?.mealScanAnalyzingStep3 ?? 'Estimating portions...',
        l10n?.mealScanAnalyzingStep4 ?? 'Calculating macros...',
        l10n?.mealScanAnalyzingStep5 ?? 'Almost there...',
      ];

  @override
  void initState() {
    super.initState();
    if (widget.mode == ScanLoadingMode.analyzing) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() {
          _index = (_index + 1) % 5;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = widget.mode == ScanLoadingMode.analyzing
        ? _analyzingSteps(l10n)
        : [l10n?.mealScanSaving ?? 'Saving meal...'];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              steps[_index.clamp(0, steps.length - 1)],
              key: ValueKey(steps[_index.clamp(0, steps.length - 1)]),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

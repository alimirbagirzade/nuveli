import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
  static const _analyzingSteps = [
    'Analyzing your meal...',
    'Identifying foods...',
    'Estimating portions...',
    'Calculating macros...',
    'Almost there...',
  ];
  static const _savingSteps = ['Saving meal...'];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.mode == ScanLoadingMode.analyzing) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() {
          _index = (_index + 1) % _analyzingSteps.length;
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
    final steps = widget.mode == ScanLoadingMode.analyzing
        ? _analyzingSteps
        : _savingSteps;
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
              steps[_index],
              key: ValueKey(steps[_index]),
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

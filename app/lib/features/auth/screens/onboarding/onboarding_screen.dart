// ============================================================================
// onboarding_screen.dart
// 5 step wrapper. PageView + üstte progress bar + altta back/next.
// Step ekranları kendi içlerinde validation yapar, parent'a "ready" sinyali
// gönderir (callback yerine direkt state'i update edip "next" callback'i
// çağırırlar).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nuveli_background.dart';
import '../../services/profile_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/onboarding_provider.dart';
import 'steps/step_1_welcome.dart';
import 'steps/step_2_personal_info.dart';
import 'steps/step_3_body_metrics.dart';
import 'steps/step_4_goals.dart';
import 'steps/step_5_targets.dart';
import 'widgets/onboarding_progress_bar.dart';

const _kTotalSteps = 5;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _submitting = false;
  String? _submitError;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _kTotalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final data = ref.read(onboardingDataProvider);
    if (!data.isComplete) {
      setState(() => _submitError = 'Please complete all steps before continuing.');
      return;
    }
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final profileService = ref.read(profileServiceProvider);
      await profileService.completeOnboarding(data);

      // Cache invalidate → AuthGate Dashboard'a yönlendirir.
      ref.invalidate(currentUserProfileProvider);

      // Draft temizle
      await ref.read(onboardingDataProvider.notifier).reset();
    } on ProfileServiceException catch (e) {
      if (mounted) setState(() => _submitError = e.message);
    } catch (_) {
      if (mounted) {
        setState(() =>
            _submitError = 'Could not save your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF142346),
        title: const Text(
          'Sign out?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your progress will be saved. You can continue setup later.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: _currentStep > 0
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white, size: 20),
                              onPressed: _submitting ? null : _back,
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: OnboardingProgressBar(
                        currentStep: _currentStep + 1,
                        totalSteps: _kTotalSteps,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: const Icon(Icons.logout,
                            color: Colors.white70, size: 18),
                        tooltip: 'Sign out',
                        onPressed: _submitting ? null : _signOut,
                      ),
                    ),
                  ],
                ),
              ),

              // STEP COUNTER
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Step ${_currentStep + 1} of $_kTotalSteps',
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.tertiaryText,
                  ),
                ),
              ),

              // BODY
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    Step1Welcome(onNext: _next),
                    Step2PersonalInfo(onNext: _next),
                    Step3BodyMetrics(onNext: _next),
                    Step4Goals(onNext: _next),
                    Step5Targets(
                      onComplete: _next,
                      submitting: _submitting,
                      submitError: _submitError,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// app/lib/features/onboarding/screens/welcome_success_screen.dart
//
// Welcome / Success — onboarding'in son ekranı.
// Kullanıcıyı sıcak bir mesajla home'a yönlendirir.
// Bu ekran sadece notification step'inden gelir; back butonu yok.

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_controller.dart';

class WelcomeSuccessScreen extends ConsumerStatefulWidget {
  const WelcomeSuccessScreen({super.key});

  @override
  ConsumerState<WelcomeSuccessScreen> createState() =>
      _WelcomeSuccessScreenState();
}

class _WelcomeSuccessScreenState
    extends ConsumerState<WelcomeSuccessScreen> {
  bool _completing = false;
  String? _errorMessage;

  Future<void> _completeAndGoHome() async {
    setState(() {
      _completing = true;
      _errorMessage = null;
    });

    final controller = ref.read(onboardingControllerProvider.notifier);

    try {
      // Notification preferences kaydet (hata olursa devam et)
      try {
        await controller.submitNotificationPrefs();
      } catch (e) {
        developer.log('⚠️  Notification prefs failed (devam ediliyor): $e');
      }
      // Onboarding'i tamamlandı işaretle (premium 'free' başlatır)
      await controller.completeOnboarding();

      if (!mounted) return;
      context.go(AppRoute.home);
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _completing = false;
        _errorMessage = e.userMessage;
      });
    } catch (e, stack) {
      debugPrint('🔴 Unknown error in welcome_success_screen.dart: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _completing = false;
        _errorMessage = 'Beklenmedik bir sorun oldu, tekrar dener misin?';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final firstName = state.displayName?.trim();
    final greeting = (firstName != null && firstName.isNotEmpty)
        ? 'Hoş geldin, $firstName.'
        : 'Hoş geldin.';

    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // Hero icon
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            greeting,
            style: AppTextStyles.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Hazırız.\nBaskı yok, yargı yok — sadece sen ve yanında bir koç.',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // İlk adım önerisi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İlk adım fikri',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Bugün ne yediğini bir öğünle başlat. Fotoğraf çek '
                  'ya da yaz — koçun gerisini hatırlasın.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error),
              ),
            ),
          ],

          const Spacer(),

          PrimaryButton(
            label: _completing ? 'Hazırlanıyor...' : 'Başlayalım',
            isEnabled: !_completing,
            onPressed: _completing ? null : _completeAndGoHome,
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

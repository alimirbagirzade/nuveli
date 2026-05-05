import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

/// Bilinmeyen route veya kritik hata durumunda gösterilir.
/// GoRouter'ın errorBuilder'ından çağrılır.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.message,
    this.title,
    this.showHomeButton = true,
  });

  final String? message;
  final String? title;
  final bool showHomeButton;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Yumuşak hata ikonu - korkutucu değil
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ).animate(),

              Text(
                title ?? 'Bir şeyler ters gitti',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message ??
                    'Beklenmeyen bir hata oluştu. Tekrar denemek için ana sayfaya dön.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              if (showHomeButton)
                PrimaryButton(
                  label: 'Ana Sayfaya Dön',
                  onPressed: () => context.go(AppRoute.home),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoute.login),
                child: const Text('Giriş ekranına git'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Widget {
  /// Animation placeholder — widget'ın kendi animation framework'ü yoksa
  /// no-op. Eklenmek istenirse flutter_animate paketi ile dolduralım.
  Widget animate() => this;
}

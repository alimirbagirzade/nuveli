// app/lib/features/onboarding/screens/calorie_preview_screen.dart
//
// Calorie Preview — PRD §5.4 step 10.
// Backend tarafından hesaplanan kalori hedefini kullanıcıya gösterir.
// Kullanıcı onayladıktan sonra notification step'e geçer.
//
// Backend submitProfile çağrısı bu ekranda yapılır (önceden değil),
// çünkü tüm onboarding alanları toplanmış oluyor:
//   goal + sensitivity + foodRelationship + profile + allergies + persona

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_controller.dart';

class CaloriePreviewScreen extends ConsumerStatefulWidget {
  const CaloriePreviewScreen({super.key});

  @override
  ConsumerState<CaloriePreviewScreen> createState() =>
      _CaloriePreviewScreenState();
}

class _CaloriePreviewScreenState
    extends ConsumerState<CaloriePreviewScreen> {
  int? _calorieTarget;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _submitProfile());
  }

  Future<void> _submitProfile() async {
    final controller = ref.read(onboardingControllerProvider.notifier);

    try {
      // Profil + tüm yeni alanlar (food_relationship, allergies, dietary)
      final result = await controller.submitProfile();
      final target = result['daily_calorie_target'] as int?;

      // Coach persona da kaydet
      await controller.submitCoachPersona();

      if (!mounted) return;
      setState(() {
        _calorieTarget = target;
        _loading = false;
      });
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.userMessage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Beklenmedik bir sorun oldu, tekrar dener misin?';
        _loading = false;
      });
    }
  }

  void _onContinue() {
    context.go(AppRoute.onboardingNotification);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Kalori', style: AppTextStyles.labelMedium),
        automaticallyImplyLeading: false, // back butonu yok, akıştan dönülmez
      ),
      padding: const EdgeInsets.all(24),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : _buildPreview(),
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.cloud_off_outlined,
            color: AppColors.textSecondary, size: 48),
        const SizedBox(height: 16),
        Text(
          _errorMessage!,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Tekrar Dene',
          onPressed: () {
            setState(() {
              _loading = true;
              _errorMessage = null;
            });
            _submitProfile();
          },
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Senin için günlük\nhedefin hazır',
          style: AppTextStyles.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Bu sayı verdiğin bilgilere göre. Sabit değil — '
          'senin günlerine göre birlikte ayarlayacağız.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),

        const SizedBox(height: 48),

        // Kalori kartı
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Günlük kalori',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                _calorieTarget != null ? '$_calorieTarget' : '—',
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'kcal',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Açıklama
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aktivite, hedef ve duruma göre hesaplandı. '
                  'Her ay yeniden gözden geçirilir.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        PrimaryButton(
          label: 'Devam Et',
          onPressed: _onContinue,
        ),
      ],
    );
  }
}

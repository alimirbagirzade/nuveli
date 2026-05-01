// app/lib/features/onboarding/screens/sensitivity_check_screen.dart
//
// Sensitivity Check — PRD §11.1.
// İki soruya cevaba göre safety_mode belirlenir:
//   normal | sensitive | high_risk
//
// KRİTİK: Yargılayıcı dil yok. "Hassasiyet" eksiklik değildir mesajı taşınır.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_controller.dart';

class SensitivityCheckScreen extends ConsumerStatefulWidget {
  const SensitivityCheckScreen({super.key});

  @override
  ConsumerState<SensitivityCheckScreen> createState() =>
      _SensitivityCheckScreenState();
}

class _SensitivityCheckScreenState
    extends ConsumerState<SensitivityCheckScreen> {
  String? _historyAnswer;
  String? _currentAnswer;

  static const _historyOptions = [
    ('no', 'Hayır, böyle bir dönem olmadı'),
    ('past_yes', 'Eskiden vardı, şimdi iyiyim'),
    ('current_yes', 'Evet, hâlâ zaman zaman zorlanıyorum'),
    ('no_answer', 'Söylemek istemiyorum'),
  ];

  static const _currentOptions = [
    ('ok', 'Rahat, kontrolüm var'),
    ('mixed', 'Karışık günlerim oluyor'),
    ('hard', 'Çoğu zaman zorluyor'),
    ('no_answer', 'Söylemek istemiyorum'),
  ];

  String _calculateSensitivityLevel() {
    if (_historyAnswer == 'current_yes' || _currentAnswer == 'hard') {
      return 'high_risk';
    }
    if (_historyAnswer == 'past_yes' || _currentAnswer == 'mixed') {
      return 'sensitive';
    }
    if (_historyAnswer == 'no_answer' || _currentAnswer == 'no_answer') {
      return 'sensitive';
    }
    return 'normal';
  }

  Map<String, dynamic> _foodRelationshipPayload() {
    return {
      'history_struggle': _historyAnswer ?? 'no_answer',
      'current_feeling': _currentAnswer ?? 'no_answer',
    };
  }

  void _onContinue() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    controller.setSensitivityLevel(_calculateSensitivityLevel());
    controller.setFoodRelationship(_foodRelationshipPayload());
    context.go(AppRoute.onboardingProfileOne);
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _historyAnswer != null && _currentAnswer != null;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Hassasiyet', style: AppTextStyles.labelMedium),
      ),
      padding: const EdgeInsets.all(24),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sana doğru tonla yardım edebilmemiz için',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu cevaplar Nuveli\'nin sana nasıl konuşacağını şekillendirir. '
              'Hassasiyet eksiklik değil — yumuşak gitmemizin yolu.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Soru 1
            Text(
              '1. Geçmişte yeme alışkanlıklarınla\nzorlandığın bir dönem oldu mu?',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            ..._historyOptions.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SensitivityCard(
                    label: opt.$2,
                    selected: _historyAnswer == opt.$1,
                    onTap: () => setState(() => _historyAnswer = opt.$1),
                  ),
                )),

            const SizedBox(height: 32),

            // Soru 2
            Text(
              '2. Şu an yiyecekle ilişkini\nnasıl tarif edersin?',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            ..._currentOptions.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SensitivityCard(
                    label: opt.$2,
                    selected: _currentAnswer == opt.$1,
                    onTap: () => setState(() => _currentAnswer = opt.$1),
                  ),
                )),

            const SizedBox(height: 32),

            // Bilgilendirme kutusu
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
                  const Icon(Icons.shield_outlined,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bu bilgiler özel kalır. Sadece koçun seninle nasıl '
                      'konuşacağını ayarlamak için kullanılır.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Devam Et',
              isEnabled: canContinue,
              onPressed: canContinue ? _onContinue : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SensitivityCard extends StatelessWidget {
  const _SensitivityCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

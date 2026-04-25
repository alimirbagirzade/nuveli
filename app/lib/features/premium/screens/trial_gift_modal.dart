import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/premium_service.dart';

/// 7 günlük ücretsiz premium denemesi teklifi.
/// Kullanıcı kabul ederse backend'de `claim_trial` çağrılır.
///
/// Kullanım:
/// ```dart
/// await TrialGiftModal.show(context);
/// ```
class TrialGiftModal extends ConsumerStatefulWidget {
  const TrialGiftModal({super.key});

  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TrialGiftModal(),
    );
  }

  @override
  ConsumerState<TrialGiftModal> createState() => _TrialGiftModalState();
}

class _TrialGiftModalState extends ConsumerState<TrialGiftModal> {
  bool _claiming = false;
  String? _errorMsg;

  Future<void> _handleClaim() async {
    setState(() {
      _claiming = true;
      _errorMsg = null;
    });

    try {
      final claimed = await ref.read(revenueCatServiceProvider).claimTrial();
      if (!mounted) return;

      if (claimed) {
        AppHaptics.success();
        // Premium status cache'ini yenile — home/paywall anında trial görsün
        ref.invalidate(premiumStatusProvider);
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMsg = 'Bu hediye zaten kullanılmış.';
          _claiming = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e is AppError ? e.userMessage : 'Bir hata oluştu.';
        _claiming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Sana bir hediye', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              '7 gün boyunca Nuveli\'nin tüm özelliklerine '
              'ücretsiz erişim. Kredi kartı gerekmez.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Özellik önizlemesi
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Sınırsız öğün analizi',
                  ),
                  const SizedBox(height: 8),
                  _FeatureRow(
                    icon: Icons.auto_awesome,
                    label: 'Gelişmiş AI koç + sesli yanıt',
                  ),
                  const SizedBox(height: 8),
                  _FeatureRow(
                    icon: Icons.insights_outlined,
                    label: 'Haftalık özet ve ilerleme',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMsg != null) ...[
              Text(
                _errorMsg!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            PrimaryButton(
              label: 'Hediyeyi Kabul Et',
              isLoading: _claiming,
              onPressed: _claiming ? null : _handleClaim,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _claiming
                  ? null
                  : () => Navigator.pop(context, false),
              child: Text(
                'Belki sonra',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}

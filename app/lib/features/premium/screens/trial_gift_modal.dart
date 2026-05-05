// app/lib/features/premium/screens/trial_gift_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_text_styles.dart';
import 'package:nuveli/features/premium/data/premium_service.dart';

class TrialGiftModal extends ConsumerStatefulWidget {
  final String? personalizedHook;

  const TrialGiftModal({super.key, this.personalizedHook});

  static Future<void> show(
    BuildContext context, {
    String? personalizedHook,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TrialGiftModal(personalizedHook: personalizedHook),
    );
  }

  @override
  ConsumerState<TrialGiftModal> createState() => _TrialGiftModalState();
}

class _TrialGiftModalState extends ConsumerState<TrialGiftModal> {
  bool _claiming = false;
  String? _error;

  Future<void> _claim() async {
    setState(() {
      _claiming = true;
      _error = null;
    });

    final svc = ref.read(premiumServiceProvider);
    final result = await svc.claimDay2Gift();

    if (!mounted) return;
    setState(() => _claiming = false);

    if (result.success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trial basladi. Yanindayiz.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (result.userCancelled) {
      // sessizce don
    } else {
      setState(() {
        _error = result.userMessage ??
            'Su an baslatamadim, biraz sonra tekrar dener misin?';
      });
    }
  }

  void _decline() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sana kucuk bir hediye',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: 8),
            if (widget.personalizedHook != null) ...[
              Text(
                widget.personalizedHook!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              '7 gun boyunca premium her seyi dene. Daha derin haftalik ozet, '
              'daha kisisel koc, sinirsiz fotograf analizi.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '7 gun ucretsiz, sonra yillik plan otomatik baslar. '
                      'Istedigin zaman ayarlardan iptal edebilirsin.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _claiming ? null : _claim,
                child: _claiming
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '7 gun ucretsiz basla',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _claiming ? null : _decline,
                child: Text(
                  'Simdi degil',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

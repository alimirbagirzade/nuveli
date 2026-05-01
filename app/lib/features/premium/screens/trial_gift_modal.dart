// app/lib/features/premium/screens/trial_gift_modal.dart
//
// Day 2 Trial Gift Modal — PRD §6.4, §7.1.
// Çerçeveleme: "Hediye", baskı veya korkutma DEĞİL.
// "Dünkü davranışı hatırlıyoruz" hissi.
//
// Kullanım: showDialog(...) ile açılır, doğrudan satın alma yapar
// (yıllık plan trial ile, RevenueCat üzerinden).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_text_styles.dart';
import 'package:nuveli/features/premium/data/premium_service.dart';

class TrialGiftModal extends ConsumerStatefulWidget {
  /// Kullanıcının dünkü ilk-isim selamlaması veya kısa mini-özet.
  /// "Ali, dün ilk öğününü kaydettin" gibi.
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
          content: Text('Trial başladı. Yanındayız.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (result.userCancelled) {
      // Kullanıcı iptal etti — sessizce dön
    } else {
      setState(() {
        _error = result.userMessage ??
            'Şu an başlatamadım, biraz sonra tekrar dener misin?';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hediye ikonu
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),

            // Başlık
            Text(
              'Sana küçük bir hediye',
              style: AppTextStyles.headlineSmall,
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

            // Alt metin
            Text(
              '7 gün boyunca premium her şeyi dene. Daha derin haftalık özet, '
              'daha kişisel koç, sınırsız fotoğraf analizi.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Net bilgi (manipülatif olmayan)
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
                      '7 gün ücretsiz, sonra yıllık plan otomatik başlar. '
                      'İstediğin zaman ayarlardan iptal edebilirsin.',
                      style: AppTextStyles.labelSmall.copyWith(
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
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // CTA — yıllık trial başlat
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
                        '7 gün ücretsiz başlat',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Decline
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _claiming ? null : _decline,
                child: Text(
                  'Şimdi değil',
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

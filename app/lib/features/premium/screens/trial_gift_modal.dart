import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/primary_button.dart';

class TrialGiftModal extends StatelessWidget {
  const TrialGiftModal({super.key});
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
              '7 gün tam erişim. Kredi kartı gerekmez.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Kabul Et',
              onPressed: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Belki sonra'),
            ),
          ],
        ),
      ),
    );
  }
}

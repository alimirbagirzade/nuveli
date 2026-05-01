import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

class EmptyDayScreen extends StatelessWidget {
  const EmptyDayScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny_outlined, size: 64, color: AppColors.warning),
            const SizedBox(height: 20),
            Text('Yeni bir gün', style: AppTextStyles.headingLarge),
            const SizedBox(height: 8),
            Text(
              'Bugün henüz kayıt yok. Başlamak için küçük bir adımla başlayalım.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            PrimaryButton(label: 'İlk Öğünü Ekle', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

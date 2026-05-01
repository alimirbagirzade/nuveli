import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Gizlilik ve Güvenlik')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Güvenliğin bizim önceliğimiz', style: AppTextStyles.headingMedium),
          const SizedBox(height: 12),
          Text(
            'Nuveli bir wellness uygulamasıdır. Tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. '
            'Zor bir dönemden geçiyorsan lütfen profesyonel destek al.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acil Destek', style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                Text('ALO 182 — Psikolojik Destek Hattı (7/24)',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _linkTile('Gizlilik Politikası', () {}),
          _linkTile('Kullanım Şartları', () {}),
          _linkTile('Verimi İndir', () {}),
        ],
      ),
    );
  }

  Widget _linkTile(String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

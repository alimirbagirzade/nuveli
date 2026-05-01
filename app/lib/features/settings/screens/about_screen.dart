import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Nuveli Hakkında')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo + version
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Nuveli', style: AppTextStyles.headingLarge),
                const SizedBox(height: 4),
                Text(
                  'AI Calorie Coach',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sürüm ${AppConfig.appVersion} (${AppConfig.appBuildNumber})',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          // Açıklama
          _section('Uygulama'),
          _info(
            'Nuveli wellness odaklı bir kalori takip uygulamasıdır. '
            'AI destekli yemek analizi, kişiselleşen koç ve davranış '
            'farkındalığı sunar.',
          ),
          const SizedBox(height: 8),
          _info(
            'Klinik beslenme veya tıbbi tedavi yerine geçmez. Diyetisyeninize '
            'danışmadan sağlık kararları vermeyin.',
          ),

          const SizedBox(height: 24),
          _section('Bağlantılar'),
          _linkRow(
            'Web sitesi',
            AppConfig.websiteUrl,
            Icons.language_outlined,
          ),
          _linkRow(
            'Gizlilik Politikası',
            AppConfig.privacyUrl,
            Icons.privacy_tip_outlined,
          ),
          _linkRow(
            'Kullanım Şartları',
            AppConfig.termsUrl,
            Icons.description_outlined,
          ),
          _linkRow(
            'Destek',
            AppConfig.supportEmail,
            Icons.email_outlined,
          ),

          const SizedBox(height: 24),
          _section('Teknik'),
          _kvRow('Ortam', AppConfig.env),
          _kvRow('Build', AppConfig.appBuildNumber),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2026 Nuveli. Tüm hakları saklıdır.',
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall,
      ),
    );
  }

  Widget _info(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall
            .copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _linkRow(String label, String value, IconData icon) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$value kopyalandı')),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodyMedium),
                    Text(
                      value,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kvRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Text(
            key,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

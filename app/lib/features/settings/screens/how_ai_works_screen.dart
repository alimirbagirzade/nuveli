import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class HowAiWorksScreen extends StatelessWidget {
  const HowAiWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('AI Nasıl Çalışır')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Block(
            icon: Icons.camera_alt_outlined,
            title: 'Yemek Tanıma',
            body: 'Fotoğrafını incelerim ve yaklaşık kalori/besin tahmini yaparım. '
                'Bu kesin bir ölçüm değildir — gerekirse düzeltebilirsin.',
          ),
          _Block(
            icon: Icons.auto_awesome,
            title: 'Koç Yanıtları',
            body: 'Kısa, yargısız ve destekleyici mesajlar üretirim. '
                'Tıbbi tavsiye ya da diyet planı sunmam.',
          ),
          _Block(
            icon: Icons.shield_outlined,
            title: 'Güvenlik',
            body: 'Riskli durumlarda profesyonel destek kaynaklarını gösteririm. '
                'Kriz anında doğrudan sabit güvenlik metni gelir.',
          ),
          _Block(
            icon: Icons.lock_outline,
            title: 'Verilerin',
            body: 'Verilerin şifreli iletilir ve sadece sen erişirsin. '
                'Ayarlar > Hesabı Sil ile tamamen silebilirsin.',
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingSmall),
                const SizedBox(height: 6),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Haftalık Özet')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatCard(title: 'Ortalama kalori', value: '1,620', unit: 'kcal/gün'),
          const SizedBox(height: 12),
          _StatCard(title: 'Kayıt tutulan gün', value: '6', unit: '/ 7'),
          const SizedBox(height: 12),
          _StatCard(title: 'Ortalama su', value: '1.8', unit: 'L/gün'),
          const SizedBox(height: 24),
          Text('İçgörüler', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          const _InsightCard(text: 'Protein alımın geçen haftaya göre %15 arttı.'),
          const SizedBox(height: 8),
          const _InsightCard(text: 'Hafta sonu öğünlerin daha kalorili oldu.'),
          const SizedBox(height: 8),
          const _InsightCard(text: 'Her gün en az bir öğün kaydettin. Harika!'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.unit});
  final String title;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppTextStyles.displayMedium),
                const TextSpan(text: '  '),
                TextSpan(text: unit, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

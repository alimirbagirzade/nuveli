import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class MonthlyInsightScreen extends StatelessWidget {
  const MonthlyInsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Aylık İçgörü')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Son 30 gün', style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text('3 önemli örüntü', style: AppTextStyles.displayMedium),
          const SizedBox(height: 24),
          _InsightBlock(
            index: '01',
            title: 'Kayıt tutulan gün',
            value: '22 / 30',
            body: 'Son bir ayda gün kayıtlarının çoğunu tuttun. Süreklilik ilerlemenin temeli.',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _InsightBlock(
            index: '02',
            title: 'Protein alımı',
            value: 'Artışta ↑',
            body: 'Ortalama protein hedefine göre %12 artış var. Öğünlerinde protein dengesi iyi.',
            color: AppColors.accent,
          ),
          const SizedBox(height: 12),
          _InsightBlock(
            index: '03',
            title: 'Hafta sonu örüntüsü',
            value: '+320 kcal',
            body: 'Cumartesi ve pazarları öğün kalorin haftadan %18 daha yüksek.',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({
    required this.index,
    required this.title,
    required this.value,
    required this.body,
    required this.color,
  });

  final String index;
  final String title;
  final String value;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(index, style: AppTextStyles.labelSmall.copyWith(color: color)),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

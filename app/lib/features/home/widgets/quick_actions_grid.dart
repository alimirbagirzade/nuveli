import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionTile(
          icon: Icons.camera_alt_outlined,
          label: 'Öğün Ekle',
          color: AppColors.primary,
          onTap: () => context.push(AppRoute.mealCapture),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.water_drop_outlined,
          label: 'Su',
          color: AppColors.info,
          onTap: () => _showWaterSheet(context),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.monitor_weight_outlined,
          label: 'Kilo',
          color: AppColors.accent,
          onTap: () => _showWeightSheet(context),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.mood_outlined,
          label: 'Check-in',
          color: AppColors.warning,
          onTap: () => _showCheckinSheet(context),
        ),
      ],
    );
  }

  void _showWaterSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => const _WaterSheet());
  }

  void _showWeightSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => const _WeightSheet());
  }

  void _showCheckinSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => const _CheckinSheet());
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sheets ─────────────────────────────────

class _WaterSheet extends StatelessWidget {
  const _WaterSheet();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Su Ekle', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [200, 250, 330, 500, 750].map((ml) {
              return ActionChip(
                label: Text('$ml ml'),
                onPressed: () => Navigator.pop(context, ml),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WeightSheet extends StatefulWidget {
  const _WeightSheet();
  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kilonu Girin', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'kg'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, double.tryParse(_ctrl.text)),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class _CheckinSheet extends StatelessWidget {
  const _CheckinSheet();
  @override
  Widget build(BuildContext context) {
    const moods = [
      ('great', '😄', 'Harika'),
      ('good', '🙂', 'İyi'),
      ('neutral', '😐', 'Normal'),
      ('bad', '😔', 'Zor'),
      ('rough', '😞', 'Çok Zor'),
    ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bugün nasılsın?', style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods.map((m) {
              return InkWell(
                onTap: () => Navigator.pop(context, m.$1),
                child: Column(
                  children: [
                    Text(m.$2, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(m.$3, style: AppTextStyles.caption),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

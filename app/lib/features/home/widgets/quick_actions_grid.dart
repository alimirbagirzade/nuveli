import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../tracking/data/tracking_repository.dart';
import '../data/home_repository.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () => _showWaterSheet(context, ref),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.monitor_weight_outlined,
          label: 'Kilo',
          color: AppColors.accent,
          onTap: () => _showWeightSheet(context, ref),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.mood_outlined,
          label: 'Mod',
          color: AppColors.warning,
          onTap: () => _showCheckinSheet(context, ref),
        ),
      ],
    );
  }

  Future<void> _showWaterSheet(BuildContext context, WidgetRef ref) async {
    final ml = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _WaterSheet(),
    );
    if (ml == null || !context.mounted) return;
    await _runWithFeedback(
      context: context,
      ref: ref,
      action: () => ref.read(trackingRepositoryProvider).addWater(ml),
      successMsg: '$ml ml su eklendi 💧',
    );
  }

  Future<void> _showWeightSheet(BuildContext context, WidgetRef ref) async {
    final kg = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _WeightSheet(),
    );
    if (kg == null || !context.mounted) return;
    await _runWithFeedback(
      context: context,
      ref: ref,
      action: () => ref.read(trackingRepositoryProvider).saveWeight(kg),
      successMsg: '${kg.toStringAsFixed(1)} kg kaydedildi ⚖️',
    );
  }

  Future<void> _showCheckinSheet(BuildContext context, WidgetRef ref) async {
    final mood = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CheckinSheet(),
    );
    if (mood == null || !context.mounted) return;
    await _runWithFeedback(
      context: context,
      ref: ref,
      action: () => ref.read(trackingRepositoryProvider).saveMood(mood),
      successMsg: 'Modun kaydedildi ✓',
    );
  }

  Future<void> _runWithFeedback({
    required BuildContext context,
    required WidgetRef ref,
    required Future<void> Function() action,
    required String successMsg,
  }) async {
    try {
      await action();
      if (!context.mounted) return;
      ref.invalidate(homePayloadProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is AppError ? e.userMessage : 'Kaydedilemedi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    }
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
          Row(
            children: [
              Text('Su Ekle', style: AppTextStyles.headingMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoute.waterHistory);
                },
                icon: const Icon(Icons.bar_chart_rounded, size: 18),
                label: const Text('Geçmiş'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.info,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ne kadar içtin?', style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [200, 250, 330, 500, 750, 1000].map((ml) {
              return InkWell(
                onTap: () => Navigator.pop(context, ml),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$ml ml', style: AppTextStyles.bodyLarge),
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

class _WeightSheet extends StatefulWidget {
  const _WeightSheet();
  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  final _ctrl = TextEditingController();

  void _submit() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (v == null || v <= 0 || v > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir kilo girin (1-500 kg).')),
      );
      return;
    }
    Navigator.pop(context, v);
  }

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
          Row(
            children: [
              Text('Kilonu Girin', style: AppTextStyles.headingMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoute.weightHistory);
                },
                icon: const Icon(Icons.show_chart_rounded, size: 18),
                label: const Text('Geçmiş'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'kg',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Kaydet'),
            ),
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
          const SizedBox(height: 8),
          Text('Bir tane seç', style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods.map((m) {
              return InkWell(
                onTap: () => Navigator.pop(context, m.$1),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(m.$2, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 6),
                      Text(m.$3, style: AppTextStyles.caption),
                    ],
                  ),
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

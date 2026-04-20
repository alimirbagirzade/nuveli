import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/meal_repository.dart';

class ManualMealEntryScreen extends ConsumerStatefulWidget {
  const ManualMealEntryScreen({super.key});
  @override
  ConsumerState<ManualMealEntryScreen> createState() => _ManualMealEntryScreenState();
}

class _ManualMealEntryScreenState extends ConsumerState<ManualMealEntryScreen> {
  final _name = TextEditingController();
  final _cal = TextEditingController();
  final _pro = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  String _mealType = 'snack';
  bool _saving = false;

  String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final calStr = _cal.text.trim();
    if (name.isEmpty || calStr.isEmpty) {
      _snack('Yemek adı ve kalori gerekli.');
      return;
    }
    final calories = int.tryParse(calStr);
    if (calories == null || calories < 0) {
      _snack('Kalori geçerli bir sayı olmalı.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(mealRepositoryProvider).manualEntry({
        'name': name,
        'calories': calories,
        'protein_g': double.tryParse(_pro.text),
        'carb_g': double.tryParse(_carb.text),
        'fat_g': double.tryParse(_fat.text),
        'local_day': _today,
        'meal_type': _mealType,
      });
      if (!mounted) return;
      _snack('Öğün eklendi.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is AppError ? e.userMessage : 'Kaydedilemedi.';
      _snack(msg);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Manuel Giriş')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(label: 'Yemek adı', ctrl: _name),
            _field(label: 'Kalori (kcal)', ctrl: _cal, number: true),
            Row(
              children: [
                Expanded(child: _field(label: 'Protein (g)', ctrl: _pro, number: true)),
                const SizedBox(width: 12),
                Expanded(child: _field(label: 'Karb (g)', ctrl: _carb, number: true)),
              ],
            ),
            _field(label: 'Yağ (g)', ctrl: _fat, number: true),
            const SizedBox(height: 8),
            Text('Öğün Tipi', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                ('breakfast', 'Kahvaltı'),
                ('lunch', 'Öğle'),
                ('dinner', 'Akşam'),
                ('snack', 'Ara öğün'),
              ].map((t) {
                final selected = _mealType == t.$1;
                return ChoiceChip(
                  label: Text(t.$2),
                  selected: selected,
                  onSelected: (_) => setState(() => _mealType = t.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Kaydet',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({required String label, required TextEditingController ctrl, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

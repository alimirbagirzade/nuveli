import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../features/home/data/home_repository.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/meal_models.dart';
import '../data/meal_repository.dart';
import '../providers/meal_providers.dart';

/// AI analiz sonucu + kullanıcı onayı/düzenlemesi.
///
/// Router `extra` ile [MealAnalysisResult] bekler.
class MealAnalysisResultScreen extends ConsumerStatefulWidget {
  const MealAnalysisResultScreen({super.key, required this.analysis});

  final MealAnalysisResult analysis;

  @override
  ConsumerState<MealAnalysisResultScreen> createState() =>
      _MealAnalysisResultScreenState();
}

class _MealAnalysisResultScreenState
    extends ConsumerState<MealAnalysisResultScreen> {
  // Editable controllers — AI önerisi ile prefill.
  late final TextEditingController _nameCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;

  String _mealType = 'snack';
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final a = widget.analysis;
    _nameCtrl = TextEditingController(text: a.suggestedName ?? '');
    _caloriesCtrl =
        TextEditingController(text: a.suggestedCalories?.toString() ?? '');
    _proteinCtrl =
        TextEditingController(text: a.suggestedProteinG?.toStringAsFixed(1) ?? '');
    _carbCtrl =
        TextEditingController(text: a.suggestedCarbG?.toStringAsFixed(1) ?? '');
    _fatCtrl =
        TextEditingController(text: a.suggestedFatG?.toStringAsFixed(1) ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // --------------------------------------------------------------------------
  // Actions
  // --------------------------------------------------------------------------

  /// "Onayla" — kullanıcı AI önerisini değişiklik yapmadan kabul etti.
  Future<void> _confirmAsIs() async {
    if (widget.analysis.analysisId == null) {
      _showError('Analiz kaydı bulunamadı.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      await ref.read(mealRepositoryProvider).confirm(
            widget.analysis.analysisId!,
            _today,
            _mealType,
          );

      if (!mounted) return;
      _showSavedAndGoHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e is AppError ? e.userMessage : 'Kaydedilemedi.';
        _isSaving = false;
      });
    }
  }

  /// "Kaydet" — kullanıcı değerleri düzenledi, edit endpoint'i çağır.
  Future<void> _saveEdited() async {
    if (widget.analysis.analysisId == null) {
      _showError('Analiz kaydı bulunamadı.');
      return;
    }

    final name = _nameCtrl.text.trim();
    final cal = int.tryParse(_caloriesCtrl.text.trim());

    if (name.isEmpty || cal == null || cal < 0) {
      _showError('Yemek adı ve geçerli kalori gerekli.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      await ref.read(mealRepositoryProvider).editAndSave(
        widget.analysis.analysisId!,
        {
          'name': name,
          'calories': cal,
          'protein_g': double.tryParse(_proteinCtrl.text.trim()),
          'carb_g': double.tryParse(_carbCtrl.text.trim()),
          'fat_g': double.tryParse(_fatCtrl.text.trim()),
          'local_day': _today,
          'meal_type': _mealType,
        },
      );

      if (!mounted) return;
      _showSavedAndGoHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e is AppError ? e.userMessage : 'Kaydedilemedi.';
        _isSaving = false;
      });
    }
  }

  void _showSavedAndGoHome() {
    AppHaptics.success();
    // Bugünkü öğün listesini + home özet/koç kartını yenile
    ref.invalidate(todayMealsProvider);
    ref.invalidate(homePayloadProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Öğün kaydedildi.')),
    );
    context.go(AppRoute.home);
  }

  void _showError(String msg) {
    setState(() => _errorMsg = msg);
  }

  // --------------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;

    // Düşük güven veya tamamen başarısız analiz → manuel girişe yönlendir.
    if (a.isLowConfidence) {
      return _LowConfidenceView(analysis: a);
    }

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Analiz Sonucu'),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Düzenle'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConfidenceBanner(confidence: a.confidence),
              const SizedBox(height: 20),

              // Yemek adı
              if (_isEditing)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Yemek adı'),
                )
              else
                Text(
                  _nameCtrl.text.isEmpty ? 'Bilinmeyen yemek' : _nameCtrl.text,
                  style: AppTextStyles.headingMedium,
                ),
              const SizedBox(height: 20),

              // Makrolar
              _MacroField(
                label: 'Kalori',
                suffix: 'kcal',
                controller: _caloriesCtrl,
                isEditing: _isEditing,
                isInt: true,
              ),
              _MacroField(
                label: 'Protein',
                suffix: 'g',
                controller: _proteinCtrl,
                isEditing: _isEditing,
              ),
              _MacroField(
                label: 'Karbonhidrat',
                suffix: 'g',
                controller: _carbCtrl,
                isEditing: _isEditing,
              ),
              _MacroField(
                label: 'Yağ',
                suffix: 'g',
                controller: _fatCtrl,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 20),

              // Öğün tipi seçimi
              Text('Öğün tipi', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ('breakfast', 'Kahvaltı'),
                  ('lunch', 'Öğle'),
                  ('dinner', 'Akşam'),
                  ('snack', 'Ara öğün'),
                ]
                    .map((m) => ChoiceChip(
                          label: Text(m.$2),
                          selected: _mealType == m.$1,
                          onSelected: (_) => setState(() => _mealType = m.$1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Hata mesajı
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => context.pop(),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _isEditing ? 'Kaydet' : 'Onayla',
                      isLoading: _isSaving,
                      onPressed: _isSaving
                          ? null
                          : (_isEditing ? _saveEdited : _confirmAsIs),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confidence banner
// ---------------------------------------------------------------------------

class _ConfidenceBanner extends StatelessWidget {
  const _ConfidenceBanner({required this.confidence});
  final String confidence;

  @override
  Widget build(BuildContext context) {
    final (icon, color, msg) = switch (confidence) {
      'high' => (
        Icons.verified_outlined,
        AppColors.success,
        'Analiz yüksek güvenle tamamlandı.',
      ),
      'medium' => (
        Icons.info_outline,
        AppColors.info,
        'Bu yaklaşık bir tahmindir. Gerekirse değerleri düzenle.',
      ),
      _ => (
        Icons.warning_amber_outlined,
        AppColors.warning,
        'Tahmin güveni düşük. Değerleri kontrol etmeni öneririz.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macro field (view or edit)
// ---------------------------------------------------------------------------

class _MacroField extends StatelessWidget {
  const _MacroField({
    required this.label,
    required this.suffix,
    required this.controller,
    required this.isEditing,
    this.isInt = false,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;
  final bool isEditing;
  final bool isInt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          if (isEditing)
            SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: suffix,
                ),
              ),
            )
          else
            Text(
              controller.text.isEmpty
                  ? '—'
                  : '${controller.text} $suffix',
              style: AppTextStyles.headingSmall,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Low-confidence / failed analysis → manuel girişe yönlendir
// ---------------------------------------------------------------------------

class _LowConfidenceView extends StatelessWidget {
  const _LowConfidenceView({required this.analysis});
  final MealAnalysisResult analysis;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Analiz Sonucu')),
      padding: const EdgeInsets.all(24),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            size: 64,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            'Emin olamadık',
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Fotoğraftan yemeği net çıkaramadık. Manuel olarak girmen daha doğru olur.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Manuel Giriş',
            onPressed: () => context.go(AppRoute.mealManual),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Farklı fotoğraf dene'),
          ),
        ],
      ),
    );
  }
}

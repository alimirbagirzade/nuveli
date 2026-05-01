import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/profile_repository.dart';

/// Personal info edit screen — all fields the user provided during
/// onboarding plus anything they want to update later.
///
/// View mode: read-only display of every field with an "edit" button.
/// Edit mode: each field becomes inline-editable; Save persists the
/// whole form in one PATCH /profile call.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() =>
      _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  bool _editing = false;
  bool _saving = false;

  // Working copy of editable fields. Filled when entering edit mode
  // from the latest snapshot of the profile, sent to the server on save.
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  int? _birthYear;
  String? _gender;
  String? _activityLevel;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _startEdit(UserProfile p) {
    setState(() {
      _editing = true;
      _nameCtrl.text = p.displayName ?? '';
      _heightCtrl.text = p.heightCm?.toStringAsFixed(0) ?? '';
      _weightCtrl.text = p.weightKg?.toStringAsFixed(1) ?? '';
      _birthYear = p.birthYear;
      _gender = p.gender;
      _activityLevel = p.activityLevel;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Pull values from controllers and only send non-empty / changed fields
      final name = _nameCtrl.text.trim();
      final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
      final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));

      await ref.read(profileRepositoryProvider).updateProfile(
            displayName: name.isEmpty ? null : name,
            heightCm: height,
            weightKg: weight,
            birthYear: _birthYear,
            gender: _gender,
            activityLevel: _activityLevel,
          );
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      setState(() {
        _editing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgiler kaydedildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(e is AppError ? e.userMessage : 'Kaydedilemedi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Kişisel Bilgiler'),
        actions: [
          if (!_editing)
            profileAsync.maybeWhen(
              data: (p) => TextButton(
                onPressed: () => _startEdit(p),
                child: const Text('Düzenle'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is AppError ? e.userMessage : 'Yüklenemedi'),
        ),
        data: (p) {
          if (_editing) return _buildEditForm(p);
          return _buildReadView(p);
        },
      ),
    );
  }

  // ─── Read mode ─────────────────────────────────────────────────────

  Widget _buildReadView(UserProfile p) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section('Hesap'),
        _ReadRow(label: 'İsim', value: p.displayName ?? '—'),
        _ReadRow(label: 'E-posta', value: p.email ?? '—'),

        const SizedBox(height: 16),
        _Section('Vücut bilgileri'),
        _ReadRow(
          label: 'Doğum yılı',
          value: p.birthYear?.toString() ?? '—',
        ),
        _ReadRow(label: 'Cinsiyet', value: _genderLabel(p.gender)),
        _ReadRow(
          label: 'Boy',
          value: p.heightCm != null ? '${p.heightCm!.toInt()} cm' : '—',
        ),
        _ReadRow(
          label: 'Kilo',
          value: p.weightKg != null
              ? '${p.weightKg!.toStringAsFixed(1)} kg'
              : '—',
        ),

        const SizedBox(height: 16),
        _Section('Aktivite'),
        _ReadRow(
          label: 'Günlük aktivite seviyesi',
          value: _activityLabel(p.activityLevel),
        ),
      ],
    );
  }

  // ─── Edit mode ─────────────────────────────────────────────────────

  Widget _buildEditForm(UserProfile p) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section('Hesap'),
        _TextField(
          label: 'İsim',
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
        ),

        const SizedBox(height: 16),
        _Section('Vücut bilgileri'),
        _BirthYearPicker(
          value: _birthYear,
          onChanged: (y) => setState(() => _birthYear = y),
        ),
        const SizedBox(height: 12),
        _GenderPicker(
          value: _gender,
          onChanged: (g) => setState(() => _gender = g),
        ),
        const SizedBox(height: 12),
        _TextField(
          label: 'Boy (cm)',
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _TextField(
          label: 'Kilo (kg)',
          controller: _weightCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
        ),

        const SizedBox(height: 16),
        _Section('Aktivite'),
        _ActivityPicker(
          value: _activityLevel,
          onChanged: (a) => setState(() => _activityLevel = a),
        ),

        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _editing = false),
                child: const Text('Vazgeç'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Labels ────────────────────────────────────────────────────────

  static String _genderLabel(String? g) {
    switch (g) {
      case 'female':
        return 'Kadın';
      case 'male':
        return 'Erkek';
      case 'other':
        return 'Diğer';
      default:
        return '—';
    }
  }

  static String _activityLabel(String? a) {
    switch (a) {
      case 'sedentary':
        return 'Hareketsiz';
      case 'light':
        return 'Hafif aktif';
      case 'moderate':
        return 'Orta aktif';
      case 'active':
        return 'Aktif';
      case 'very_active':
        return 'Çok aktif';
      default:
        return '—';
    }
  }
}

// ─── Reusable widgets ────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _ReadRow extends StatelessWidget {
  const _ReadRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
        ),
      );
}

class _BirthYearPicker extends StatelessWidget {
  const _BirthYearPicker({required this.value, required this.onChanged});
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(80, (i) => DateTime.now().year - 12 - i);
    return DropdownButtonFormField<int>(
      value: value,
      hint: const Text('Doğum yılı'),
      decoration: InputDecoration(
        labelText: 'Doğum yılı',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Cinsiyet',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'female', child: Text('Kadın')),
        DropdownMenuItem(value: 'male', child: Text('Erkek')),
        DropdownMenuItem(value: 'other', child: Text('Diğer')),
      ],
      onChanged: onChanged,
    );
  }
}

class _ActivityPicker extends StatelessWidget {
  const _ActivityPicker({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Aktivite seviyesi',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'sedentary', child: Text('Hareketsiz (masa başı)')),
        DropdownMenuItem(value: 'light', child: Text('Hafif aktif (1-3 gün)')),
        DropdownMenuItem(value: 'moderate', child: Text('Orta aktif (3-5 gün)')),
        DropdownMenuItem(value: 'active', child: Text('Aktif (6-7 gün)')),
        DropdownMenuItem(value: 'very_active', child: Text('Çok aktif (sporcu)')),
      ],
      onChanged: onChanged,
    );
  }
}

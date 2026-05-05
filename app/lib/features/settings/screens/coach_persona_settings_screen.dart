// app/lib/features/settings/screens/coach_persona_settings_screen.dart
//
// Coach Persona Settings — kullanici onboarding'den sonra koc tonunu degistirebilir.
// PRD §6.7
//
// 4 PRD persona: gentle | funny | direct | calm
// Her birinin kisa preview metni var, "Koc senle soyle konusur" hissi.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';

class CoachPersonaSettingsScreen extends ConsumerStatefulWidget {
  const CoachPersonaSettingsScreen({super.key});

  @override
  ConsumerState<CoachPersonaSettingsScreen> createState() =>
      _CoachPersonaSettingsScreenState();
}

class _CoachPersonaSettingsScreenState
    extends ConsumerState<CoachPersonaSettingsScreen> {
  String? _selected;
  String? _initialPersona;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  static const _personas = [
    (
      'gentle',
      'Nazik',
      'Yumuşak, baskısız, empati önce',
      '"Bugün biraz zor olduğunu görüyorum. '
          'Bir öğün eksik kalsa da kendine sert davranma."',
    ),
    (
      'funny',
      'Esprili',
      'Hafif, gülümseten, ciddi anlarda dengeli',
      '"Pizza akşamı, anladım. Hayat zaten bir denge işi — '
          'yarın salata, bu akşam mutluluk."',
    ),
    (
      'direct',
      'Doğrudan',
      'Kısa, net, gerçekçi geri bildirim',
      '"Bugün protein az. Akşam yemekte 25-30g hedefle, '
          'hafta dengesi tutar."',
    ),
    (
      'calm',
      'Sakin',
      'Yargılamayan, sabırlı, ölçülü',
      '"Düşünmeden yedik bazen. Önemli olan farkına varmak. '
          'Sonraki öğüne odaklanalım."',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrent());
  }

  Future<void> _loadCurrent() async {
    try {
      final dio = ref.read(apiClientProvider);
      final res = await dio.get('/profile');
      final data = res.data?['data'] as Map<String, dynamic>?;
      final coachPrefs = data?['coach_preferences'] as Map<String, dynamic>?;
      final persona = coachPrefs?['coach_persona'] as String?;
      if (!mounted) return;
      setState(() {
        _initialPersona = persona;
        _selected = persona ?? 'gentle';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selected = 'gentle';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selected == null || _selected == _initialPersona) {
      context.pop();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/profile/coach-preferences',
          data: {'coach_persona': _selected});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.coachToneUpdated),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) context.pop();
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Kaydedemedim. Bağlantını kontrol edip tekrar dener misin?';
      });
      debugPrint('CoachPersonaSettings save: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Beklenmedik bir sorun oldu, tekrar dener misin?';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.coachSettingsTitle, style: AppTextStyles.labelMedium),
      ),
      padding: const EdgeInsets.all(24),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Koçun seninle nasıl konuşsun?',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'İstediğin zaman değiştirebilirsin.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: ListView.separated(
                    itemCount: _personas.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = _personas[i];
                      final selected = _selected == p.$1;
                      return _PersonaCard(
                        title: p.$2,
                        tagline: p.$3,
                        sample: p.$4,
                        selected: selected,
                        onTap: () => setState(() => _selected = p.$1),
                      );
                    },
                  ),
                ),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],

                PrimaryButton(
                  label: _saving ? 'Kaydediliyor...' : 'Kaydet',
                  isEnabled: !_saving && _selected != null,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  const _PersonaCard({
    required this.title,
    required this.tagline,
    required this.sample,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String tagline;
  final String sample;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headingMedium),
                      const SizedBox(height: 2),
                      Text(
                        tagline,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 14),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                sample,
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

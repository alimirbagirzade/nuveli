import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_controller.dart';

// ═══════════════════════════════════════════════════════
// GOAL SELECTION
// ═══════════════════════════════════════════════════════
class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingControllerProvider).goal;
    final controller = ref.read(onboardingControllerProvider.notifier);

    const goals = [
      ('lose_weight', 'Kilo vermek', 'Sürdürülebilir ve yargısız şekilde'),
      ('maintain', 'Kiloyu korumak', 'Denge ve farkındalık'),
      ('gain_muscle', 'Kilo almak', 'Sağlıklı şekilde'),
    ];

    return AppScaffold(
      appBar: AppBar(title: Text('Hedef', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hedefin ne?', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text(
            'İstediğin zaman değiştirebilirsin.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ...goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SelectionCard(
                  title: g.$2,
                  subtitle: g.$3,
                  selected: selected == g.$1,
                  onTap: () => controller.setGoal(g.$1),
                ),
              )),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: selected != null,
            onPressed: selected == null
                ? null
                : () => context.go(AppRoute.onboardingSensitivity),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
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
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PROFILE STEP 1 — demographics
// ═══════════════════════════════════════════════════════
class ProfileStepOneScreen extends ConsumerStatefulWidget {
  const ProfileStepOneScreen({super.key});

  @override
  ConsumerState<ProfileStepOneScreen> createState() =>
      _ProfileStepOneScreenState();
}

class _ProfileStepOneScreenState extends ConsumerState<ProfileStepOneScreen> {
  late final TextEditingController _yearCtrl;
  String? _gender;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _yearCtrl = TextEditingController(text: data.birthYear?.toString() ?? '');
    _gender = data.gender;
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  bool get _valid {
    if (_yearCtrl.text.length != 4) return false;
    final year = int.tryParse(_yearCtrl.text);
    if (year == null) return false;
    final age = DateTime.now().year - year;
    // 18+ age gate + makul aralık
    return age >= 18 && age <= 100 && _gender != null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingControllerProvider.notifier);

    return AppScaffold(
      appBar:
          AppBar(title: Text('Profil 1/2', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sen nasıl birisin?', style: AppTextStyles.displayMedium),
          const SizedBox(height: 24),
          TextField(
            controller: _yearCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: 'Doğum yılı',
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Cinsiyet', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              ('male', 'Erkek'),
              ('female', 'Kadın'),
              ('other', 'Diğer'),
              ('prefer_not', 'Söylemek istemiyorum'),
            ]
                .map((g) => ChoiceChip(
                      label: Text(g.$2),
                      selected: _gender == g.$1,
                      onSelected: (_) => setState(() => _gender = g.$1),
                    ))
                .toList(),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: _valid,
            onPressed: !_valid
                ? null
                : () {
                    controller.setProfileBasics(
                      birthYear: int.parse(_yearCtrl.text),
                      gender: _gender!,
                    );
                    context.go(AppRoute.onboardingProfileTwo);
                  },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PROFILE STEP 2 — body + activity
// ═══════════════════════════════════════════════════════
class ProfileStepTwoScreen extends ConsumerStatefulWidget {
  const ProfileStepTwoScreen({super.key});

  @override
  ConsumerState<ProfileStepTwoScreen> createState() =>
      _ProfileStepTwoScreenState();
}

class _ProfileStepTwoScreenState extends ConsumerState<ProfileStepTwoScreen> {
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  String? _activity;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _heightCtrl = TextEditingController(
      text: data.heightCm?.toInt().toString() ?? '',
    );
    _weightCtrl = TextEditingController(
      text: data.weightKg?.toInt().toString() ?? '',
    );
    _activity = data.activityLevel;
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  bool get _valid {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h == null || h < 100 || h > 250) return false;
    if (w == null || w < 30 || w > 300) return false;
    return _activity != null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingControllerProvider.notifier);

    return AppScaffold(
      appBar:
          AppBar(title: Text('Profil 2/2', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Birkaç ölçüm daha', style: AppTextStyles.displayMedium),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Boy (cm)'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Text('Aktivite düzeyin', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          ...[
            ('sedentary', 'Çok az hareket', 'Masa başı, az yürüyüş'),
            ('light', 'Hafif aktif', 'Haftada 1-3 egzersiz'),
            ('moderate', 'Orta aktif', 'Haftada 3-5 egzersiz'),
            ('active', 'Çok aktif', 'Haftada 6+ egzersiz'),
          ].map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectionCard(
                  title: a.$2,
                  subtitle: a.$3,
                  selected: _activity == a.$1,
                  onTap: () => setState(() => _activity = a.$1),
                ),
              )),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: _valid,
            onPressed: !_valid
                ? null
                : () {
                    controller.setPhysical(
                      heightCm: double.parse(_heightCtrl.text),
                      weightKg: double.parse(_weightCtrl.text),
                      activityLevel: _activity!,
                    );
                    context.go(AppRoute.onboardingAllergies);
                  },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// COACH SELECTION
// ═══════════════════════════════════════════════════════
class CoachSelectionScreen extends ConsumerWidget {
  const CoachSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(onboardingControllerProvider).coachPersona;
    final controller = ref.read(onboardingControllerProvider.notifier);

    const personas = [
      ('gentle', 'Nazik', 'Yumuşak, baskısız, empati önce'),
      ('funny', 'Esprili', 'Hafif, gülümseten, ciddi anlarda dengeli'),
      ('direct', 'Doğrudan', 'Kısa, net, gerçekçi geri bildirim'),
      ('calm', 'Sakin', 'Yargılamayan, sabırlı, ölçülü'),
    ];

    return AppScaffold(
      appBar: AppBar(title: Text('Koçun', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Koçun nasıl konuşsun?', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text(
            'İstediğin zaman değiştirebilirsin.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ...personas.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SelectionCard(
                  title: p.$2,
                  subtitle: p.$3,
                  selected: persona == p.$1,
                  onTap: () => controller.setCoachPersona(p.$1),
                ),
              )),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: persona != null,
            onPressed: persona == null
                ? null
                : () => context.go(AppRoute.onboardingCaloriePreview),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// NOTIFICATION OPT-IN
// ═══════════════════════════════════════════════════════
class NotificationOptInScreen extends ConsumerWidget {
  const NotificationOptInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);

    return AppScaffold(
      appBar:
          AppBar(title: Text('Bildirimler', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hafif hatırlatmalar ister misin?',
              style: AppTextStyles.displayMedium),
          const SizedBox(height: 12),
          Text(
            'Koçundan kısa destek ve öğün hatırlatmaları. Sessiz saatlere saygı duyarız.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Evet, istiyorum',
            onPressed: () {
              controller.setNotificationPrefs(
                mealReminders: true,
                coachNudges: true,
                weeklySummary: true,
              );
              context.go(AppRoute.onboardingSuccess);
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Şimdilik hayır',
            onPressed: () {
              controller.setNotificationPrefs(
                mealReminders: false,
                coachNudges: false,
                weeklySummary: false,
              );
              context.go(AppRoute.onboardingSuccess);
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ONBOARDING RESULT — backend submit + calorie display
// ═══════════════════════════════════════════════════════
class OnboardingResultScreen extends ConsumerStatefulWidget {
  const OnboardingResultScreen({super.key});

  @override
  ConsumerState<OnboardingResultScreen> createState() =>
      _OnboardingResultScreenState();
}

class _OnboardingResultScreenState
    extends ConsumerState<OnboardingResultScreen> {
  int? _calorieTarget;
  String? _errorMsg;
  bool _isSubmitting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _submitToBackend());
  }

  Future<void> _submitToBackend() async {
    final controller = ref.read(onboardingControllerProvider.notifier);

    try {
      // 1. Profil + goal kaydet, backend kalori hedefini döner
      final profileResult = await controller.submitProfile();
      final target = profileResult['daily_calorie_target'] as int?;

      // 2. Koç persona kaydet
      await controller.submitCoachPersona();

      // 3. Notification prefs kaydet
      await controller.submitNotificationPrefs();

      // 4. Onboarding'i kapat + bootstrap'i yenile
      await controller.completeOnboarding();

      if (!mounted) return;
      AppHaptics.success();
      setState(() {
        _calorieTarget = target ?? _fallbackTarget();
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      AppHaptics.error();
      setState(() {
        _errorMsg =
            'Kaydetme başarısız. İnternet bağlantını kontrol et ve tekrar dene.';
        _isSubmitting = false;
      });
    }
  }

  /// Backend'e ulaşılamazsa local fallback hesabı.
  int _fallbackTarget() {
    final data = ref.read(onboardingControllerProvider);
    if (data.weightKg == null ||
        data.heightCm == null ||
        data.birthYear == null) {
      return 2000;
    }
    final age = DateTime.now().year - data.birthYear!;
    final bmr = data.gender == 'male'
        ? 10 * data.weightKg! + 6.25 * data.heightCm! - 5 * age + 5
        : 10 * data.weightKg! + 6.25 * data.heightCm! - 5 * age - 161;
    final factor = {
          'sedentary': 1.2,
          'light': 1.375,
          'moderate': 1.55,
          'active': 1.725,
        }[data.activityLevel] ??
        1.375;
    double tdee = bmr * factor;
    if (data.goal == 'lose_weight') tdee -= 500;
    if (data.goal == 'gain_muscle') tdee += 300;
    final minimum = data.gender == 'male' ? 1500 : 1200;
    return tdee.toInt().clamp(minimum, 4000);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return const AppScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Hazırlanıyor...'),
            ],
          ),
        ),
      );
    }

    if (_errorMsg != null) {
      return AppScaffold(
        padding: const EdgeInsets.all(24),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Bir sorun oluştu',
              style: AppTextStyles.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Tekrar Dene',
              onPressed: () {
                setState(() {
                  _errorMsg = null;
                  _isSubmitting = true;
                });
                _submitToBackend();
              },
            ),
          ],
        ),
      );
    }

    final target = _calorieTarget ?? 2000;

    return AppScaffold(
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text('Hazırsın 👋', style: AppTextStyles.displayLarge),
          const SizedBox(height: 12),
          Text(
            'Tahmini günlük hedefin:',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '$target',
                  style: AppTextStyles.displayLarge
                      .copyWith(color: AppColors.primary),
                ),
                Text('kcal / gün', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu yaklaşık bir başlangıç noktasıdır. İlerledikçe ayarlanabilir.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'İlk öğünümü ekleyelim',
            onPressed: () => context.go(AppRoute.mealCapture),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Ana ekrana geç',
            onPressed: () => context.go(AppRoute.home),
          ),
        ],
      ),
    );
  }
}

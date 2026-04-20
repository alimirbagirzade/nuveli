import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

/// Onboarding state — bu dosyadaki tüm ekranlar arasında paylaşılır.
/// Production'da Riverpod provider ile değiştirilecek.
class OnboardingData {
  String? goal;
  int? birthYear;
  String? gender;
  double? heightCm;
  double? weightKg;
  String? activityLevel;
  String? coachPersona;
  bool? notificationOptIn;
}

final onboardingData = OnboardingData();


// ═══════════════════════════════════════════════════════
// GOAL SELECTION
// ═══════════════════════════════════════════════════════
class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});
  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selected;

  final _goals = const [
    ('lose', 'Kilo vermek', 'Sürdürülebilir ve yargısız şekilde'),
    ('maintain', 'Kiloyu korumak', 'Denge ve farkındalık'),
    ('gain', 'Kilo almak', 'Sağlıklı şekilde'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('Hedef', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hedefin ne?', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('İstediğin zaman değiştirebilirsin.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          ..._goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  title: g.$2,
                  subtitle: g.$3,
                  selected: _selected == g.$1,
                  onTap: () => setState(() => _selected = g.$1),
                ),
              )),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: _selected != null,
            onPressed: () {
              onboardingData.goal = _selected;
              context.go(AppRoute.onboardingProfileOne);
            },
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
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
                width: 24, height: 24,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
class ProfileStepOneScreen extends StatefulWidget {
  const ProfileStepOneScreen({super.key});
  @override
  State<ProfileStepOneScreen> createState() => _ProfileStepOneScreenState();
}

class _ProfileStepOneScreenState extends State<ProfileStepOneScreen> {
  final _yearCtrl = TextEditingController();
  String? _gender;

  @override
  Widget build(BuildContext context) {
    final valid = _yearCtrl.text.length == 4 && _gender != null;
    return AppScaffold(
      appBar: AppBar(title: Text('Profil 1/2', style: AppTextStyles.labelMedium)),
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
            decoration: const InputDecoration(labelText: 'Doğum yılı', counterText: ''),
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
            ].map((g) => ChoiceChip(
                  label: Text(g.$2),
                  selected: _gender == g.$1,
                  onSelected: (_) => setState(() => _gender = g.$1),
                )).toList(),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: valid,
            onPressed: () {
              onboardingData.birthYear = int.parse(_yearCtrl.text);
              onboardingData.gender = _gender;
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
class ProfileStepTwoScreen extends StatefulWidget {
  const ProfileStepTwoScreen({super.key});
  @override
  State<ProfileStepTwoScreen> createState() => _ProfileStepTwoScreenState();
}

class _ProfileStepTwoScreenState extends State<ProfileStepTwoScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _activity;

  @override
  Widget build(BuildContext context) {
    final valid = _heightCtrl.text.isNotEmpty && _weightCtrl.text.isNotEmpty && _activity != null;
    return AppScaffold(
      appBar: AppBar(title: Text('Profil 2/2', style: AppTextStyles.labelMedium)),
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
                child: _GoalCard(
                  title: a.$2, subtitle: a.$3,
                  selected: _activity == a.$1,
                  onTap: () => setState(() => _activity = a.$1),
                ),
              )),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: valid,
            onPressed: () {
              onboardingData.heightCm = double.parse(_heightCtrl.text);
              onboardingData.weightKg = double.parse(_weightCtrl.text);
              onboardingData.activityLevel = _activity;
              context.go(AppRoute.onboardingCoach);
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
class CoachSelectionScreen extends StatefulWidget {
  const CoachSelectionScreen({super.key});
  @override
  State<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends State<CoachSelectionScreen> {
  String? _persona;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('Koçun', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Koçun nasıl konuşsun?', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('İstediğin zaman değiştirebilirsin.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          ...[
            ('supportive', 'Destekleyici', 'Nazik, sakin, empati önce'),
            ('motivating', 'Motive edici', 'Enerjik, hedef odaklı'),
            ('realistic', 'Gerçekçi', 'Doğrudan ama şefkatli'),
          ].map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  title: p.$2, subtitle: p.$3,
                  selected: _persona == p.$1,
                  onTap: () => setState(() => _persona = p.$1),
                ),
              )),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: _persona != null,
            onPressed: () {
              onboardingData.coachPersona = _persona;
              context.go(AppRoute.onboardingNotification);
            },
          ),
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════
// NOTIFICATION OPT-IN
// ═══════════════════════════════════════════════════════
class NotificationOptInScreen extends StatelessWidget {
  const NotificationOptInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('Bildirimler', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hafif hatırlatmalar ister misin?', style: AppTextStyles.displayMedium),
          const SizedBox(height: 12),
          Text(
            'Koçundan kısa destek ve öğün hatırlatmaları. Sessiz saatlere saygı duyarız.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Evet, istiyorum',
            onPressed: () {
              onboardingData.notificationOptIn = true;
              context.go(AppRoute.onboardingResult);
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Şimdilik hayır',
            onPressed: () {
              onboardingData.notificationOptIn = false;
              context.go(AppRoute.onboardingResult);
            },
          ),
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════
// ONBOARDING RESULT
// ═══════════════════════════════════════════════════════
class OnboardingResultScreen extends StatelessWidget {
  const OnboardingResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basit Mifflin-St Jeor hesaplaması (backend da hesaplar)
    final data = onboardingData;
    int target = 2000;
    if (data.weightKg != null && data.heightCm != null && data.birthYear != null) {
      final age = DateTime.now().year - data.birthYear!;
      final bmr = data.gender == 'male'
          ? 10 * data.weightKg! + 6.25 * data.heightCm! - 5 * age + 5
          : 10 * data.weightKg! + 6.25 * data.heightCm! - 5 * age - 161;
      final factor = {
        'sedentary': 1.2, 'light': 1.375, 'moderate': 1.55, 'active': 1.725,
      }[data.activityLevel] ?? 1.375;
      double tdee = bmr * factor;
      if (data.goal == 'lose') tdee -= 500;
      if (data.goal == 'gain') tdee += 300;
      final min = data.gender == 'male' ? 1500 : 1200;
      target = tdee.toInt().clamp(min, 4000);
    }

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
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                Text('$target', style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary)),
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
            onPressed: () => context.go(AppRoute.mealEntry),
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

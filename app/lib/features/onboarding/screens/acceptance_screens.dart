import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../widgets/acceptance_template.dart';

/// 2/5 — Wellness scope.
class WellnessScopeScreen extends StatelessWidget {
  const WellnessScopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AcceptanceTemplate(
      stepLabel: '2 / 5',
      title: 'Nuveli bir wellness uygulamasıdır',
      body:
          'Nuveli tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. '
          'Özel sağlık durumların için doktorundan destek alman önemli.',
      checkboxLabel: 'Anladım. Nuveli doktorumun yerini almaz.',
      onBack: () => context.pop(),
      onContinue: () => context.go(AppRoute.acceptanceAiEstimates),
    );
  }
}

/// 3/5 — AI tahminleri.
class AiEstimatesScreen extends StatelessWidget {
  const AiEstimatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AcceptanceTemplate(
      stepLabel: '3 / 5',
      title: 'AI tahminleri yaklaşıktır',
      body:
          'Yemek fotoğraflarından yaptığımız kalori ve besin değeri tahminleri '
          'yaklaşık sonuçlardır. Her zaman düzenleyebilirsin.',
      checkboxLabel: 'Sonuçların yaklaşık olabileceğini biliyorum.',
      onBack: () => context.pop(),
      onContinue: () => context.go(AppRoute.acceptanceSpecialCases),
    );
  }
}

/// 4/5 — Özel durumlar.
class SpecialCasesScreen extends StatelessWidget {
  const SpecialCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AcceptanceTemplate(
      stepLabel: '4 / 5',
      title: 'Özel durumlarda dikkat',
      body:
          'Hamilelik, emzirme, yeme bozukluğu geçmişi veya kronik hastalığın '
          'varsa, kalori önerilerini uygulamadan önce sağlık uzmanına danış.',
      checkboxLabel: 'Özel durumumda uzmana danışacağım.',
      onBack: () => context.pop(),
      onContinue: () => context.go(AppRoute.acceptanceTerms),
    );
  }
}

/// 5/5 — Şartlar & gizlilik.
class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AcceptanceTemplate(
      stepLabel: '5 / 5',
      title: 'Şartlar ve gizlilik',
      body:
          'Kullanım Şartları ve Gizlilik Politikası\'nı okuyup kabul etmelisin. '
          'Verilerin güvende tutulur ve ayarlar ekranından her zaman silebilirsin.',
      checkboxLabel: 'Şartları ve Gizlilik Politikası\'nı kabul ediyorum.',
      onBack: () => context.pop(),
      onContinue: () => context.go(AppRoute.onboardingGoal),
    );
  }
}

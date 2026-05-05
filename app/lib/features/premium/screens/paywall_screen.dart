// app/lib/features/premium/screens/paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_text_styles.dart';
import 'package:nuveli/features/premium/data/premium_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String source;

  const PaywallScreen({super.key, this.source = 'manual'});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _loadingOfferings = true;
  bool _purchasing = false;
  String? _errorMessage;
  List<PremiumOffering> _offerings = [];
  String? _selectedIdentifier;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _errorMessage = null;
    });

    try {
      final svc = ref.read(premiumServiceProvider);
      final offerings = await svc.getOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = offerings;
        if (offerings.isNotEmpty) {
          _selectedIdentifier = offerings
              .firstWhere(
                (o) =>
                    o.identifier.toLowerCase().contains('annual') ||
                    o.identifier.toLowerCase().contains('yearly'),
                orElse: () => offerings.first,
              )
              .identifier;
        }
        _loadingOfferings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Premium yakinda aktif olacak. Su anlik beklemede.';
        _loadingOfferings = false;
      });
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedIdentifier == null) return;
    final selected =
        _offerings.firstWhere((o) => o.identifier == _selectedIdentifier);

    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });

    final svc = ref.read(premiumServiceProvider);
    final result = await svc.purchase(selected);

    if (!mounted) return;
    setState(() => _purchasing = false);

    if (result.success) {
      _showSuccessAndPop();
    } else if (result.userCancelled) {
      // sessizce don
    } else {
      setState(() {
        _errorMessage = result.userMessage ??
            'Satin alma tamamlanamadi, biraz sonra dener misin?';
      });
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });

    final svc = ref.read(premiumServiceProvider);
    final result = await svc.restore();

    if (!mounted) return;
    setState(() => _purchasing = false);

    if (result.success && result.newStatus?.isPremium == true) {
      _showSuccessAndPop();
    } else if (!result.success) {
      setState(() {
        _errorMessage = result.userMessage ??
            'Geri yuklenecek bir premium bulunamadi';
      });
    } else {
      setState(() {
        _errorMessage = 'Bu hesaba bagli premium bulunamadi';
      });
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium aktif. Yanindayiz.'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: _purchasing ? null : _handleRestore,
                      child: const Text(
                        'Geri yukle',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHero(),
                      const SizedBox(height: 32),
                      _buildValueProps(),
                      const SizedBox(height: 32),
                      _buildOfferings(),
                      const SizedBox(height: 16),
                      if (_errorMessage != null) _buildError(),
                      const SizedBox(height: 24),
                      _buildCta(),
                      const SizedBox(height: 16),
                      _buildLegalNote(),
                    ]),
                  ),
                ),
              ],
            ),
            if (_purchasing)
              Container(
                color: Colors.black54,
                child:
                    const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daha cok seni\ntaniyan koc.',
          style: AppTextStyles.displayLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Ucretsiz surum seni takip eder, premium surum seni tanir.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildValueProps() {
    final items = [
      ('Daha derin haftalik ozet', 'Oruntulerini fark eden, sicak yorum'),
      ('Daha kisisel koc tonu', 'Seni hatirlayan, sana gore konusan'),
      ('Daha erken uyari',
          'Riskli aliskanliklar gorunmeden acilmadan once'),
      ('Sinirsiz fotograf analizi', 'Gunde 10 ogune kadar tahmin'),
      ('Sesli koc', 'Kisa, sicak ve kisisel sesli yanitlar'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1, style: AppTextStyles.bodyLarge),
                          const SizedBox(height: 2),
                          Text(
                            item.$2,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildOfferings() {
    if (_loadingOfferings) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_offerings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Premium yakinda. Su an seceneklere ulasilamiyor.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton(
                onPressed: _loadOfferings,
                child: const Text('Tekrar dene')),
          ],
        ),
      );
    }

    return Column(
      children: _offerings
          .map((offering) => _buildOfferingCard(offering))
          .toList(),
    );
  }

  Widget _buildOfferingCard(PremiumOffering offering) {
    final isSelected = _selectedIdentifier == offering.identifier;
    final isYearly = offering.identifier.toLowerCase().contains('annual') ||
        offering.identifier.toLowerCase().contains('yearly');

    return GestureDetector(
      onTap: () =>
          setState(() => _selectedIdentifier = offering.identifier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isYearly ? 'Yillik' : 'Aylik',
                        style: AppTextStyles.headingSmall,
                      ),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'En cok secilen',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offering.displayPrice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (offering.hasFreeTrial &&
                      offering.trialDays != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${offering.trialDays} gün ücretsiz dene, sonra otomatik yenilenir',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCta() {
    final disabled = _loadingOfferings ||
        _purchasing ||
        _selectedIdentifier == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: disabled ? null : _handlePurchase,
        child: Text(
          _selectedIdentifier != null && _hasTrialFor(_selectedIdentifier!)
              ? 'Ucretsiz dene'
              : 'Devam et',
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  bool _hasTrialFor(String identifier) {
    if (_offerings.isEmpty) return false;
    final o = _offerings.firstWhere(
      (x) => x.identifier == identifier,
      orElse: () => _offerings.first,
    );
    return o.hasFreeTrial;
  }

  Widget _buildLegalNote() {
    return Text(
      'Aboneligi istedigin zaman App Store / Play Store ayarlarindan iptal edebilirsin. '
      'Trial sona ermeden 24 saat once iptal etmediginde otomatik yenilenir.',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}

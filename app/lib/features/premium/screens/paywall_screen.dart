import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/premium_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _busy = false;

  Future<void> _purchase() async {
    final offering = ref.read(revenueCatOfferingProvider).valueOrNull;
    final pkg = offering?.monthly ?? offering?.availablePackages.firstOrNull;
    if (pkg == null) {
      _showMessage('Şu an satın alma seçeneği yüklenemedi. Sonra dene.');
      return;
    }

    setState(() => _busy = true);
    final result = await ref.read(revenueCatServiceProvider).purchasePackage(pkg);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case PurchaseSuccess(hasPremium: final hp):
        if (hp) {
          // Premium state'i yenile
          ref.invalidate(premiumStatusProvider);
          if (mounted) Navigator.pop(context, true);
        }
      case PurchaseCancelled():
        break; // sessiz
      case PurchaseFailure(message: final m):
        _showMessage(m);
      case PurchaseNotConfigured():
        _showMessage('Satın alma şu an kullanılamıyor.');
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    final result = await ref.read(revenueCatServiceProvider).restorePurchases();
    if (!mounted) return;
    setState(() => _busy = false);

    if (result is PurchaseSuccess && result.hasPremium) {
      ref.invalidate(premiumStatusProvider);
      _showMessage('Premium geri yüklendi.');
    } else {
      _showMessage('Geri yüklenebilecek satın alma yok.');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      ('Sınırsız öğün analizi', Icons.camera_alt_outlined),
      ('Gelişmiş AI koç + sesli yanıt', Icons.auto_awesome),
      ('Haftalık özet ve aylık içgörü', Icons.insights_outlined),
      ('Tüm ilerleme grafikleri', Icons.trending_up_rounded),
      ('Öncelikli destek', Icons.support_agent_outlined),
    ];

    final offeringAsync = ref.watch(revenueCatOfferingProvider);
    final priceLabel = offeringAsync.when(
      data: (offering) {
        final pkg = offering?.monthly ?? offering?.availablePackages.firstOrNull;
        return pkg?.storeProduct.priceString ?? '—';
      },
      loading: () => '...',
      error: (_, __) => '—',
    );

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('NUVELI PREMIUM',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryLight)),
            ),
            const SizedBox(height: 16),
            Text('Tüm özellikler,\nsınır yok.', style: AppTextStyles.displayLarge),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: features.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final (text, icon) = features[i];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: AppColors.primaryLight, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('7 gün ücretsiz dene', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text('Sonrasında $priceLabel/ay · istediğin zaman iptal et',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: '7 Gün Ücretsiz Başla',
              isLoading: _busy,
              onPressed: _purchase,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _busy ? null : _restore,
                child: Text('Satın almayı geri yükle', style: AppTextStyles.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

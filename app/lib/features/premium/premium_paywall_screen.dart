// lib/features/premium/premium_paywall_screen.dart
//
// Ana paywall ekranı. Underwater liquid glass tema.
//
// Bölümler (yukardan aşağı):
//   1. Close button (x) sağ üstte
//   2. Hero — parıltılı premium icon + headline
//   3. Feature list (8 item)
//   4. Package selector (Monthly / Annual / Lifetime kartları)
//   5. CTA button — "Start 7-day free trial"
//   6. Footer — Restore / Terms / Privacy + "Cancel anytime"
//
// Route: `/premium` (Chat 17'de tanımlanır)
// Argüman: source (hangi feature'dan geldi)

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/network/app_error.dart';
import '../../shared/widgets/app_error_view.dart';
import 'models/premium_features.dart';
import 'models/premium_offering.dart';
import 'models/premium_package.dart';
import 'providers/offerings_provider.dart';
import 'providers/purchase_provider.dart';
import 'widgets/premium_cta_button.dart';
import 'widgets/premium_feature_card.dart';
import 'widgets/premium_package_card.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  /// Hangi feature'dan geldiği (örn: "ai_coach", "analytics", "meal_planner").
  /// Headline kontekstine yön verir.
  final String? source;

  /// Subscribe başarılı olduğunda gidilecek route. Null ise success screen.
  final String? successRoute;

  const PremiumPaywallScreen({
    super.key,
    this.source,
    this.successRoute,
  });

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  PremiumPackage? _selectedPackage;
  bool _bootstrappedSelection = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final purchaseState = ref.watch(purchaseProvider);

    // Purchase başarılı → success screen veya geri dön
    ref.listen<PurchaseState>(purchaseProvider, (prev, next) {
      if (next is PurchaseSuccessful) {
        _onPurchaseSuccess(next);
      } else if (next is PurchaseErrored) {
        _showErrorSnackbar(next.message);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050A1F),
              Color(0xFF0B1A3D),
              Color(0xFF050A1F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: offeringsAsync.when(
            loading: _buildLoading,
            error: (e, _) => _buildError(e),
            data: (offering) {
              if (offering.isEmpty) {
                return _buildError(
                  'No subscription packages available. '
                  'Please check your connection and try again.',
                );
              }

              // İlk frame'de default paketi seç
              if (!_bootstrappedSelection) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedPackage = offering.defaultPackage;
                      _bootstrappedSelection = true;
                    });
                  }
                });
              }

              return _buildContent(offering, purchaseState);
            },
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF00D4FF)),
      ),
    );
  }

  /// `errorOrMessage` accepts either an Object/Exception coming out of
  /// AsyncValue.error, or a plain String for "no packages" style soft
  /// failures we surface ourselves. Both routes funnel through
  /// AppErrorView so the icon + title stay consistent.
  Widget _buildError(Object errorOrMessage) {
    final error = errorOrMessage is String
        ? AppError.unknown(errorOrMessage)
        : AppError.from(errorOrMessage);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(offeringsProvider),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6E7B91)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PremiumOffering offering, PurchaseState purchaseState) {
    final isLoading = purchaseState is PurchaseLoading;

    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          slivers: [
            // Hero
            SliverToBoxAdapter(child: _buildHero()),

            // Feature list
            SliverToBoxAdapter(child: _buildFeatureList()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Package selector
            SliverToBoxAdapter(child: _buildPackageList(offering)),

            // Bottom CTA + footer
            SliverToBoxAdapter(
              child: _buildBottomSection(isLoading: isLoading),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),

        // Close button (üstte, fixed)
        Positioned(
          top: 8,
          right: 8,
          child: _buildCloseButton(),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────
  // Hero
  // ───────────────────────────────────────────────────────────

  Widget _buildHero() {
    final headline = PremiumFeatures.headlineForSource(widget.source);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      child: Column(
        children: [
          // Glowing icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFF00D4FF),
                  Color(0xFF0099CC),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                  blurRadius: 48,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nuveli Premium',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4DDBFF),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Try free for 7 days. Cancel anytime.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFB8C5D6),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Feature list
  // ───────────────────────────────────────────────────────────

  Widget _buildFeatureList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF142346).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              children: [
                for (final item in PremiumFeatures.all)
                  PremiumFeatureCard(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Package selector
  // ───────────────────────────────────────────────────────────

  Widget _buildPackageList(PremiumOffering offering) {
    // Sıralama: Annual → Lifetime → Monthly (annual baş, satış maks.)
    final ordered = [
      offering.findByType(PremiumPackageType.annual),
      offering.findByType(PremiumPackageType.lifetime),
      offering.findByType(PremiumPackageType.monthly),
    ].where((p) => p != null).cast<PremiumPackage>().toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          for (var i = 0; i < ordered.length; i++) ...[
            PremiumPackageCard(
              package: ordered[i],
              isSelected: _selectedPackage?.raw.identifier ==
                  ordered[i].raw.identifier,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedPackage = ordered[i]);
              },
            ),
            if (i < ordered.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Bottom CTA + footer
  // ───────────────────────────────────────────────────────────

  Widget _buildBottomSection({required bool isLoading}) {
    final selected = _selectedPackage;
    final ctaLabel = _ctaLabelFor(selected);
    final ctaSubtitle = _ctaSubtitleFor(selected);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        children: [
          PremiumCtaButton(
            label: ctaLabel,
            subtitle: ctaSubtitle,
            isEnabled: selected != null && !isLoading,
            isLoading: isLoading,
            onPressed: () {
              if (selected != null) {
                HapticFeedback.mediumImpact();
                ref.read(purchaseProvider.notifier).purchase(selected);
              }
            },
          ),
          const SizedBox(height: 16),

          // Footer links
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              _FooterLink(
                label: 'Restore',
                onTap: isLoading
                    ? null
                    : () => ref.read(purchaseProvider.notifier).restore(),
              ),
              const _FooterDot(),
              _FooterLink(
                label: 'Terms',
                onTap: () => _openUrl(AppConfig.termsUrl),
              ),
              const _FooterDot(),
              _FooterLink(
                label: 'Privacy',
                onTap: () => _openUrl(AppConfig.privacyUrl),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Apple 3.1.2(a) + Play Console subscription policy: spell out
          // auto-renewal + the cancel window + where to manage. A bare
          // "cancel anytime" is the classic reject trigger because it
          // doesn't tell the user WHERE or by WHEN.
          const Text(
            'Subscriptions auto-renew at the end of each period unless '
            'canceled at least 24 hours before. Manage in your Apple ID / '
            'Google Play account settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: Color(0xFF6E7B91),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFB8C5D6),
              size: 18,
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // CTA label helpers
  // ───────────────────────────────────────────────────────────

  String _ctaLabelFor(PremiumPackage? package) {
    if (package == null) return 'Select a plan';
    if ((package.freeTrialDays ?? 0) > 0) {
      return 'Start ${package.freeTrialDays}-day free trial';
    }
    if (package.type == PremiumPackageType.lifetime) {
      return 'Get Lifetime';
    }
    return 'Subscribe — ${package.priceString}';
  }

  String? _ctaSubtitleFor(PremiumPackage? package) {
    if (package == null) return null;
    if ((package.freeTrialDays ?? 0) > 0) {
      return 'Then ${package.priceString}, ${package.description.toLowerCase()}';
    }
    if (package.type == PremiumPackageType.annual &&
        package.monthlyEquivalentString != null) {
      return '${package.monthlyEquivalentString}, billed annually';
    }
    return null;
  }

  // ───────────────────────────────────────────────────────────
  // Side effects
  // ───────────────────────────────────────────────────────────

  void _onPurchaseSuccess(PurchaseSuccessful state) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();

    if (widget.successRoute != null) {
      Navigator.of(context).pushReplacementNamed(widget.successRoute!);
    } else {
      // Default: success screen
      Navigator.of(context).pushReplacementNamed('/premium/success');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF142346),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ───────────────────────────────────────────────────────────────

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _FooterLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onTap == null
                ? const Color(0xFF4A5670)
                : const Color(0xFFB8C5D6),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF6E7B91),
          ),
        ),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '·',
        style: TextStyle(color: Color(0xFF6E7B91), fontSize: 12),
      ),
    );
  }
}

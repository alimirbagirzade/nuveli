// lib/features/settings/widgets/premium_settings_section.dart
//
// Settings ekranına eklenecek subscription status section.
//
// Davranış:
//   - Premium user: "Premium Active" + expire tarihi + Manage Subscription linki
//   - Free user:    "Free Plan" + Upgrade CTA
//   - Her durumda:  Restore Purchases butonu (App Store kuralı)
//
// Kullanım (Settings screen içinde):
//   ListView(
//     children: [
//       ...,
//       const PremiumSettingsSection(),
//       ...,
//     ],
//   )

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../premium/providers/premium_provider.dart';
import '../../premium/providers/purchase_provider.dart';
import '../../premium/services/revenue_cat_service.dart';
import '../../premium/widgets/premium_badge.dart';

class PremiumSettingsSection extends ConsumerStatefulWidget {
  const PremiumSettingsSection({super.key});

  @override
  ConsumerState<PremiumSettingsSection> createState() =>
      _PremiumSettingsSectionState();
}

class _PremiumSettingsSectionState
    extends ConsumerState<PremiumSettingsSection> {
  DateTime? _expiresAt;
  bool _loadingExpiry = true;

  @override
  void initState() {
    super.initState();
    _loadExpiry();
  }

  Future<void> _loadExpiry() async {
    final exp = await RevenueCatService.instance.premiumExpiresAt();
    if (mounted) {
      setState(() {
        _expiresAt = exp;
        _loadingExpiry = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final purchaseState = ref.watch(purchaseProvider);
    final isRestoring = purchaseState is PurchaseLoading &&
        (purchaseState).isRestore;

    // Restore başarılı / başarısız → snackbar
    ref.listen<PurchaseState>(purchaseProvider, (prev, next) {
      if (next is PurchaseSuccessful && next.wasRestore) {
        _showSnack('Purchases restored successfully', isError: false);
        _loadExpiry();
      } else if (next is PurchaseErrored) {
        _showSnack(next.message, isError: true);
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? const Color(0xFF00D4FF).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          _StatusHeader(
            isPremium: isPremium,
            expiresAt: _expiresAt,
            loadingExpiry: _loadingExpiry,
          ),
          _Divider(),
          if (isPremium)
            _ManageSubscriptionTile()
          else
            _UpgradeTile(),
          _Divider(),
          _RestoreTile(
            isLoading: isRestoring,
            onTap: isRestoring
                ? null
                : () => ref.read(purchaseProvider.notifier).restore(),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isError ? const Color(0xFF5C2030) : const Color(0xFF1A3D2F),
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  final bool isPremium;
  final DateTime? expiresAt;
  final bool loadingExpiry;

  const _StatusHeader({
    required this.isPremium,
    required this.expiresAt,
    required this.loadingExpiry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          // Icon halo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isPremium
                  ? const RadialGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                    )
                  : null,
              color: isPremium ? null : Colors.white.withValues(alpha: 0.08),
              boxShadow: isPremium
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_outline_rounded,
              color: isPremium ? Colors.white : const Color(0xFFB8C5D6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPremium ? 'Premium' : 'Free Plan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      const PremiumBadge(height: 18, compact: true),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitleText(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8C5D6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitleText() {
    if (!isPremium) return 'Unlock everything with Premium';
    if (loadingExpiry) return 'Loading subscription details...';
    if (expiresAt == null) {
      return 'Lifetime access — thank you!';
    }
    final now = DateTime.now();
    final isFuture = expiresAt!.isAfter(now);
    final formatted =
        '${expiresAt!.day.toString().padLeft(2, '0')}.${expiresAt!.month.toString().padLeft(2, '0')}.${expiresAt!.year}';
    return isFuture ? 'Renews on $formatted' : 'Expired on $formatted';
  }
}

class _UpgradeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        '/premium',
        arguments: {'source': 'settings'},
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D4FF),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF00D4FF),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageSubscriptionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openManageSubscription(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Color(0xFFB8C5D6),
            ),
          ],
        ),
      ),
    );
  }

  /// Platform-specific subscription management.
  /// iOS: App Store subscriptions page
  /// Android: Play Store subscriptions page
  Future<void> _openManageSubscription() async {
    final url = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse(
            'https://play.google.com/store/account/subscriptions'
            '?package=com.nuveli.app',
          );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _RestoreTile extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _RestoreTile({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: onTap == null
                      ? const Color(0xFF6E7B91)
                      : const Color(0xFFB8C5D6),
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF00D4FF)),
                ),
              )
            else
              const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Color(0xFFB8C5D6),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

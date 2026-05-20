// lib/features/premium/widgets/premium_upsell_dialog.dart
//
// Free user bir premium feature'a erişmeye çalıştığında çıkan modal.
// Kontekstüel başlık (source'a göre) + kısa feature listesi + "Upgrade" CTA.
//
// Kullanım:
//   final goPaywall = await PremiumUpsellDialog.show(context, source: 'analytics');
//   if (goPaywall == true) context.push('/premium');

import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/premium_features.dart';
import 'premium_cta_button.dart';

class PremiumUpsellDialog extends StatelessWidget {
  final String? source;

  const PremiumUpsellDialog({super.key, this.source});

  /// Modal'ı aç. Dönüş: `true` → kullanıcı "Upgrade" dedi, paywall'a git.
  /// `false`/`null` → "Maybe later" veya dış tıklama.
  static Future<bool?> show(BuildContext context, {String? source}) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => PremiumUpsellDialog(source: source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headline = PremiumFeatures.headlineForSource(source);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF142346),
                  Color(0xFF0B1A3D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Halo icon
                  Container(
                    width: 64,
                    height: 64,
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
                          color: const Color(0xFF00D4FF).withOpacity(0.5),
                          blurRadius: 32,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Try Premium free for 7 days',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8C5D6),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mini feature list (3 item)
                  ...PremiumFeatures.shortlist.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF00D4FF),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CTA
                  PremiumCtaButton(
                    label: 'Start 7-day free trial',
                    subtitle: 'Then \$4.99/mo, billed annually',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  const SizedBox(height: 8),

                  // Dismiss
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6E7B91),
                    ),
                    child: const Text(
                      'Maybe later',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// lib/features/premium/widgets/premium_cta_button.dart
//
// Paywall'daki ana "Start Free Trial" / "Subscribe" CTA butonu.
// Cyan gradient + glow + loading state + disabled state.

import 'package:flutter/material.dart';

class PremiumCtaButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const PremiumCtaButton({
    super.key,
    required this.label,
    this.subtitle,
    this.isLoading = false,
    this.isEnabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !isEnabled || isLoading;
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: disabled ? 0.55 : 1.0,
        child: Container(
          width: double.infinity,
          height: subtitle != null ? 64 : 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.45),
                      blurRadius: 28,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF050A1F)),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF050A1F),
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF050A1F).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

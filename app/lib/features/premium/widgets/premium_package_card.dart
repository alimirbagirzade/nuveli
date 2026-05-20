// lib/features/premium/widgets/premium_package_card.dart
//
// Paket seçim kartı (Monthly / Annual / Lifetime).
// Seçili olunca cyan border + glow + scale animasyonu.
// "Most Popular" badge (annual) ve "Save X%" badge (annual/lifetime) içeride.

import 'package:flutter/material.dart';

import '../models/premium_package.dart';

class PremiumPackageCard extends StatelessWidget {
  final PremiumPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const PremiumPackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cyan = const Color(0xFF00D4FF);
    final cardBg = const Color(0xFF142346).withOpacity(0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? cyan
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cyan.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Row(
                children: [
                  // Radio indicator
                  _RadioIndicator(isSelected: isSelected),
                  const SizedBox(width: 14),

                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              package.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (package.freeTrialDays != null &&
                                package.freeTrialDays! > 0) ...[
                              const SizedBox(width: 8),
                              _TrialPill(days: package.freeTrialDays!),
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

                  // Price block
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.priceString,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (package.monthlyEquivalentString != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          package.monthlyEquivalentString!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6E7B91),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // "Most Popular" / "Best Value" badge — kartın üstünden taşar
            if (package.isMostPopular || package.isBestValue)
              Positioned(
                top: -10,
                left: 16,
                child: _TopBadge(
                  label: package.isMostPopular ? 'MOST POPULAR' : 'BEST VALUE',
                ),
              ),

            // Save % badge — sağ üstte
            if (package.savingsPercent != null && package.savingsPercent! > 0)
              Positioned(
                top: -10,
                right: 16,
                child: _SavingsBadge(percent: package.savingsPercent!),
              ),
          ],
        ),
      ),
    );
  }

  String _subtitleText() {
    if (package.type == PremiumPackageType.annual) {
      return 'Billed yearly • Cancel anytime';
    }
    if (package.type == PremiumPackageType.lifetime) {
      return 'One-time payment • Yours forever';
    }
    if (package.type == PremiumPackageType.monthly) {
      return 'Billed monthly • Cancel anytime';
    }
    return package.description;
  }
}

// ───────────────────────────────────────────────────────────────

class _RadioIndicator extends StatelessWidget {
  final bool isSelected;
  const _RadioIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00D4FF)
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        color: isSelected ? const Color(0xFF00D4FF) : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Color(0xFF050A1F))
          : null,
    );
  }
}

class _TopBadge extends StatelessWidget {
  final String label;
  const _TopBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF050A1F),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SavingsBadge extends StatelessWidget {
  final int percent;
  const _SavingsBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3DDC97),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3DDC97).withOpacity(0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        'SAVE $percent%',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF050A1F),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _TrialPill extends StatelessWidget {
  final int days;
  const _TrialPill({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        '$days-DAY FREE',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4DDBFF),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

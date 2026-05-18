import 'package:flutter/material.dart';

import 'nuveli_card.dart';

enum StreakCardSize { small, large }

/// Ardışık gün serisi kartı.
///
/// Small (Görsel 3): "Daily Streak | 12 days" + 6 alev ikonu satırı (son slot boş)
/// Large (Görsel 7): Yatay layout, büyük alev ikonu + "18 day streak"
class StreakCard extends StatelessWidget {
  final int streakDays;
  final String? title;
  final String? subtitle;
  final int totalSlots; // small varyantta gösterilecek slot sayısı
  final StreakCardSize size;

  const StreakCard({
    super.key,
    required this.streakDays,
    this.title,
    this.subtitle,
    this.totalSlots = 6,
    this.size = StreakCardSize.small,
  });

  @override
  Widget build(BuildContext context) {
    return size == StreakCardSize.small ? _buildSmall() : _buildLarge();
  }

  Widget _buildSmall() {
    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$streakDays',
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'days',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _FireRow(streakDays: streakDays, totalSlots: totalSlots),
        ],
      ),
    );
  }

  Widget _buildLarge() {
    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const _FireGlowIcon(size: 56),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays day streak',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? "Keep it up! You're doing great.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FireRow extends StatelessWidget {
  final int streakDays;
  final int totalSlots;

  const _FireRow({required this.streakDays, required this.totalSlots});

  @override
  Widget build(BuildContext context) {
    // Son slot her zaman "gelecek hedef" olarak boş kalır (görsel referans gibi)
    final filled = (streakDays).clamp(0, totalSlots - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSlots, (i) {
        final isFilled = i < filled;
        final isLast = i == totalSlots - 1;
        return _FireSlot(filled: isFilled, isTarget: isLast && !isFilled);
      }),
    );
  }
}

class _FireSlot extends StatelessWidget {
  final bool filled;
  final bool isTarget;

  const _FireSlot({required this.filled, required this.isTarget});

  @override
  Widget build(BuildContext context) {
    if (isTarget) {
      // Boş hedef: outline damla ikonu
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.water_drop_outlined,
          size: 14,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B35), Color(0xFFFF9F45)],
              )
            : null,
        color: filled ? null : AppColors.textTertiary.withValues(alpha: 0.2),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        size: 18,
        color: filled
            ? Colors.white
            : AppColors.textSecondary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _FireGlowIcon extends StatelessWidget {
  final double size;

  const _FireGlowIcon({this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFFF9F45)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        size: size * 0.55,
        color: Colors.white,
      ),
    );
  }
}

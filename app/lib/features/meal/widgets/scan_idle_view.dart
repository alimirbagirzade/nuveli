import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../premium/premium_paywall_screen.dart';
import '../providers/meal_scan_controller.dart';
import '../providers/scan_count_provider.dart';

/// Entry view: camera + gallery CTAs, with a daily-quota badge for
/// free users. Tapping a CTA while gated routes to the paywall.
class ScanIdleView extends ConsumerWidget {
  const ScanIdleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateAsync = ref.watch(scanGateProvider);
    final controller = ref.read(mealScanControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          gateAsync.when(
            data: (gate) => _CounterBadge(gate: gate),
            loading: () => const SizedBox(height: 32),
            error: (_, __) => const SizedBox(height: 32),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Illustration(),
                const SizedBox(height: 28),
                const Text(
                  'Snap your meal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Point your camera at your plate. Nuveli\'s AI will '
                    'estimate calories and macros in a few seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB8D4D2),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _ScanCta(
            icon: Icons.camera_alt_rounded,
            label: 'Take photo',
            primary: true,
            onPressed: () => _handleTap(context, ref, gateAsync, () {
              controller.pickFromCamera();
            }),
          ),
          const SizedBox(height: 12),
          _ScanCta(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            primary: false,
            onPressed: () => _handleTap(context, ref, gateAsync, () {
              controller.pickFromGallery();
            }),
          ),
        ],
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ScanGateStatus> gateAsync,
    VoidCallback proceed,
  ) {
    final gate = gateAsync.valueOrNull;
    if (gate == null) {
      proceed();
      return;
    }
    if (!gate.canScan) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PremiumPaywallScreen(source: 'meal_scan'),
        ),
      );
      return;
    }
    proceed();
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.gate});
  final ScanGateStatus gate;

  @override
  Widget build(BuildContext context) {
    final color = gate.canScan ? AppColors.primary : AppColors.warning;
    final icon = gate.isPremium ? Icons.workspace_premium : Icons.bolt;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              gate.counterLabel,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.accent.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: const Icon(
        Icons.restaurant_rounded,
        size: 56,
        color: AppColors.primary,
      ),
    );
  }
}

class _ScanCta extends StatelessWidget {
  const _ScanCta({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: primary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.photo_library_outlined,
                  color: Colors.white),
              label: Text(label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}

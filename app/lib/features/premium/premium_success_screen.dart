// lib/features/premium/premium_success_screen.dart
//
// Subscribe başarılı olunca gösterilen celebration ekranı.
// Glow + scale animasyonu (lottie/confetti yerine kendi animasyon — bağımlılık az).
//
// Route: `/premium/success`

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumSuccessScreen extends StatefulWidget {
  /// Devam butonuna basılınca nereye gidilecek.
  /// Default: ana ekran ('/dashboard').
  final String continueRoute;

  const PremiumSuccessScreen({
    super.key,
    this.continueRoute = '/dashboard',
  });

  @override
  State<PremiumSuccessScreen> createState() => _PremiumSuccessScreenState();
}

class _PremiumSuccessScreenState extends State<PremiumSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Açılış haptic + animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.lightImpact();
      _scaleCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Animated halo
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleCtrl, _pulseCtrl]),
                  builder: (_, __) {
                    final scale = Curves.elasticOut.transform(_scaleCtrl.value);
                    final pulseScale = 1.0 + (_pulseCtrl.value * 0.06);
                    final glowOpacity = 0.4 + (_pulseCtrl.value * 0.3);
                    return Transform.scale(
                      scale: scale * pulseScale,
                      child: Container(
                        width: 140,
                        height: 140,
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
                              color: const Color(0xFF00D4FF)
                                  .withOpacity(glowOpacity),
                              blurRadius: 60,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                FadeTransition(
                  opacity: _scaleCtrl,
                  child: const Column(
                    children: [
                      Text(
                        'Welcome to Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Every feature is unlocked. '
                          'Your AI coach just got way more useful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFB8C5D6),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // CTA
                FadeTransition(
                  opacity: _scaleCtrl,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        widget.continueRoute,
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00D4FF).withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: -2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Start exploring',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF050A1F),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

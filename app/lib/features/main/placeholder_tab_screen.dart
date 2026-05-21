import 'package:flutter/material.dart';

/// "Coming soon" panel for bottom-nav tabs whose underlying feature
/// hasn't shipped yet (Scan, Analytics in v1.0). Replaces the previous
/// snackbar-on-tap approach which Apple App Review would flag as a
/// dead button.
///
/// Showing a dedicated screen explains *what* will eventually live
/// here, points to the closest existing workflow in v1.0 (Dashboard
/// for meal logging, Profile for weekly progress), and gives a real
/// thumbnail so reviewers and users see intent rather than emptiness.
class PlaceholderTabScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const PlaceholderTabScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050A1F), Color(0xFF0B1A3D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF142346).withValues(alpha: 0.6),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: const Color(0xFF4DDBFF), size: 44),
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF4DDBFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB8C5D6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Henüz inşa edilmemiş ekranlar için geçici "Yakında" görünümü.
///
/// İlgili Chat tamamlanınca bu placeholder yerine gerçek screen import
/// edilmeli (app_router.dart içindeki TODO yorumlarına bak).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle = 'Yakında geliyor',
    this.chatHint,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final String? chatHint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF00D4FF).withOpacity(0.6)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFB8C5D6),
              ),
            ),
            if (chatHint != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  chatHint!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E7B91),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_button.dart';
import 'route_paths.dart';

/// 404 / yönlendirme hatası ekranı.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NuveliBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Color(0xFFFF5C5C),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sayfa Bulunamadı',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aradığın sayfa mevcut değil veya taşınmış olabilir.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8C5D6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E7B91),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 32),
                  NuveliButton(
                    text: 'Ana Sayfaya Dön',
                    onPressed: () => context.go(Routes.dashboard),
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

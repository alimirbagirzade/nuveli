// app/lib/features/auth/screens/verify_email_screen.dart
//
// Email Doğrulama Ekranı
// Signup sonrası kullanıcıyı tutar, email doğrulanana kadar app'e geçemez.
// 5 saniyede bir Supabase'den session refresh ederek email_confirmed_at kontrol eder.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routing/app_router.dart';
import '../providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _pollingTimer;
  bool _resending = false;
  String? _resendError;
  String? _resendSuccess;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Her 5 saniyede bir session refresh
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkVerification();
    });
  }

  Future<void> _checkVerification() async {
    // Polling stratejisi: signInWithPassword ile login dene.
    // - Henüz verify olmamışsa Supabase "Email not confirmed" hatası verir → bekle
    // - Verify olmuşsa session açılır → /acceptance'a git
    try {
      final creds = ref.read(pendingSignupCredentialsProvider);
      if (creds == null) {
        // Credentials yok - kullanıcı app'i kapatıp açmış olabilir.
        // Mevcut user'a güven (eski getUser() davranışı fallback).
        final user = Supabase.instance.client.auth.currentUser;
        if (user?.emailConfirmedAt != null) {
          _pollingTimer?.cancel();
          if (mounted) context.go(AppRoute.acceptanceAgeGate);
        }
        return;
      }

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: creds.email,
        password: creds.password,
      );

      if (response.user?.emailConfirmedAt != null) {
        _pollingTimer?.cancel();
        // Credentials'ı temizle - artık ihtiyacımız yok
        ref.read(pendingSignupCredentialsProvider.notifier).state = null;
        if (mounted) {
          context.go(AppRoute.acceptanceAgeGate);
        }
      }
    } on AuthException catch (e) {
      // "Email not confirmed" hatası beklenen - kullanıcı henüz tıklamamış
      // Diğer hataları da sessizce yut, bir sonraki polling cycle'ı dener
      if (e.message.toLowerCase().contains('not confirmed') ||
          e.message.toLowerCase().contains('not verified')) {
        return;
      }
      // Beklenmeyen auth hatası - log için debug print
      debugPrint('Verify polling auth error: ${e.message}');
    } catch (e) {
      // Network vs - sessizce devam
      debugPrint('Verify polling error: $e');
    }
  }

  Future<void> _resendEmail() async {
    if (_resending || _resendCooldown > 0) return;

    setState(() {
      _resending = true;
      _resendError = null;
      _resendSuccess = null;
    });

    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) {
        throw Exception('Email bulunamadı');
      }

      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      if (!mounted) return;
      setState(() {
        _resendSuccess = AppLocalizations.of(context)!.verifyEmailResent;
        _resendCooldown = 60; // 60 saniye bekle
      });

      // Cooldown timer başlat
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _resendCooldown--;
            if (_resendCooldown <= 0) {
              timer.cancel();
            }
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _resendError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      context.go(AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Mail ikonu
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l.verifyEmailTitle,
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l.verifyEmailSubtitle(email),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          l.verifyEmailWaitingTitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.verifyEmailWaitingBody,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_resendSuccess != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _resendSuccess!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_resendError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _resendError!,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: _resendCooldown > 0
                    ? l.verifyEmailResendIn(_resendCooldown.toString())
                    : l.verifyEmailResend,
                onPressed: (_resendCooldown > 0 || _resending) ? null : _resendEmail,
                isLoading: _resending,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _signOut,
                child: Text(
                  l.verifyEmailSignOut,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

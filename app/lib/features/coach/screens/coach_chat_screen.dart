import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../data/coach_repository.dart';
import '../widgets/coach_message_bubble.dart';

class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({super.key});

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _ctrl.clear();

    try {
      AppHaptics.light();
      await ref.read(coachChatProvider.notifier).sendMessage(text);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      if (e is LimitExceededError) {
        await _showCoachLimitDialog(e.userMessage);
        return;
      }
      final msg = e is AppError ? e.userMessage : 'Mesaj gönderilemedi.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _showCoachLimitDialog(String reason) async {
    final goToPaywall = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_outline,
            size: 48, color: AppColors.primary),
        title: const Text('Günlük mesaj limiti doldu'),
        content: Text(
          '$reason\n\nPremium ile sınırsız koç sohbeti + sesli yanıtlara erişebilirsin.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Sonra'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Premium\'a bak'),
          ),
        ],
      ),
    );

    if (goToPaywall == true && mounted) {
      context.push(AppRoute.paywall);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(coachChatProvider);
    final riskMode =
        ref.watch(coachChatProvider.notifier).lastRiskMode;

    return AppScaffold(
      appBar: AppBar(title: const Text('Koçun')),
      body: Column(
        children: [
          if (riskMode == 'crisis' || riskMode == 'distress')
            _SupportBanner(isCrisis: riskMode == 'crisis'),
          Expanded(
            child: chatAsync.when(
              loading: () => _CoachChatSkeleton(),
              error: (err, _) {
                final msg = err is AppError ? err.userMessage : 'Yüklenemedi.';
                return Center(child: Text(msg, style: AppTextStyles.bodySmall));
              },
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Merhaba! Bugün nasıl hissediyorsun?',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    // reverse:true draws bottom-up; flip the index so
                    // the newest message is rendered at the visual bottom.
                    final m = messages[messages.length - 1 - i];
                    return CoachMessageBubble(message: m);
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    enabled: !_sending,
                    decoration: const InputDecoration(hintText: 'Mesajını yaz...'),
                  ),
                ),
                IconButton(
                  icon: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Crisis/distress durumunda üstte çıkan destek banner'ı.
/// Koç AI'si bu durumlarda yanıt vermiyor; kullanıcıya profesyonel yönlendirme.
class _SupportBanner extends StatelessWidget {
  const _SupportBanner({required this.isCrisis});
  final bool isCrisis;

  @override
  Widget build(BuildContext context) {
    final bg = isCrisis
        ? AppColors.error.withOpacity(0.12)
        : AppColors.warning.withOpacity(0.12);
    final fg = isCrisis ? AppColors.error : AppColors.warning;

    final title = isCrisis
        ? 'Şu an yalnız değilsin'
        : 'Zor bir an geçiriyor olabilirsin';
    final body = isCrisis
        ? 'Bu konuda seninle olmak istiyoruz ama doğru destek için bir uzmana '
            'ulaşman çok önemli.'
        : 'Koçun bu tür durumlarda yardımcı olamaz. Seninle ilgilenen birine '
            'ulaşmak her zaman bir seçenek.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCrisis ? Icons.favorite_outline : Icons.info_outline,
                size: 18,
                color: fg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              _SupportLink(
                label: '182 — Aile Danışma',
                uri: 'tel:182',
              ),
              const SizedBox(width: 12),
              _SupportLink(
                label: 'Türk Tabipleri B.',
                uri: 'https://www.ttb.org.tr/',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportLink extends StatelessWidget {
  const _SupportLink({required this.label, required this.uri});
  final String label;
  final String uri;

  Future<void> _openOrCopy(BuildContext context) async {
    final parsed = Uri.tryParse(uri);
    if (parsed != null) {
      final canOpen = await canLaunchUrl(parsed);
      if (canOpen) {
        // Telefon açmayı tel: için dene, web için externalApplication
        final mode = parsed.scheme == 'tel'
            ? LaunchMode.externalApplication
            : LaunchMode.externalApplication;
        final launched = await launchUrl(parsed, mode: mode);
        if (launched) return;
      }
    }
    // Fallback: URL'i clipboard'a kopyala
    if (!context.mounted) return;
    await Clipboard.setData(ClipboardData(text: uri));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$uri kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: () => _openOrCopy(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Chat yüklenirken gösterilen skeleton — 2 coach + 1 user bubble yer tutucusu.
class _CoachChatSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // Coach bubble (sol)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 28, height: 28, borderRadius: 14),
            SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 220, height: 44, borderRadius: 16),
                  SizedBox(height: 4),
                  SkeletonBox(width: 60, height: 10),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // User bubble (sağ)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonBox(width: 140, height: 36, borderRadius: 16),
                  SizedBox(height: 4),
                  SkeletonBox(width: 40, height: 10),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Coach bubble (sol, daha uzun)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 28, height: 28, borderRadius: 14),
            SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 260, height: 60, borderRadius: 16),
                  SizedBox(height: 4),
                  SkeletonBox(width: 60, height: 10),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

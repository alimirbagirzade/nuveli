import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VoiceReplyPlayer extends StatefulWidget {
  const VoiceReplyPlayer({super.key, required this.audioUrl});
  final String audioUrl;

  @override
  State<VoiceReplyPlayer> createState() => _VoiceReplyPlayerState();
}

class _VoiceReplyPlayerState extends State<VoiceReplyPlayer> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _playing = !_playing),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text('Sesli dinle', style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}

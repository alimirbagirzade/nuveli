import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Renders a user avatar.
///
/// Resolution order:
///   1. If [photoUrl] is non-null and non-empty, show that image
///      (network-backed, e.g. uploaded to Supabase Storage).
///   2. Otherwise fall back to a DiceBear illustration determined
///      by [style] + [seed].
///
/// DiceBear is free for unlimited use, no key required.
class NuveliAvatar extends StatelessWidget {
  const NuveliAvatar({
    super.key,
    required this.style,
    required this.seed,
    this.photoUrl,
    this.size = 64,
    this.backgroundColor,
  });

  /// One of: lorelei, peep, bottts, adventurer, fun-emoji
  final String style;

  /// Any string. Same seed → same avatar deterministically.
  final String seed;

  /// Optional uploaded photo URL. Takes precedence over generated avatar.
  final String? photoUrl;

  final double size;
  final Color? backgroundColor;

  static const _baseUrl = 'https://api.dicebear.com/7.x';

  String get _url {
    final query = StringBuffer('seed=${Uri.encodeComponent(seed)}');
    query.write('&backgroundColor=transparent');
    if (style == 'lorelei' || style == 'adventurer') {
      query.write('&radius=50');
    }
    return '$_baseUrl/$style/svg?$query';
  }

  bool get _hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.15);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _hasPhoto
            ? Image.network(
                photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (ctx, child, prog) {
                  if (prog == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              )
            : SvgPicture.network(
                _url,
                width: size,
                height: size,
                placeholderBuilder: (_) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() => Center(
        child: Icon(
          Icons.person_outline,
          size: size * 0.5,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      );
}

/// Constants for the avatar styles we support across the app.
class AvatarStyles {
  static const all = <String>[
    'lorelei',
    'peep',
    'bottts',
    'adventurer',
    'fun-emoji',
  ];

  static String label(String style) {
    switch (style) {
      case 'lorelei':
        return 'Lorelei';
      case 'peep':
        return 'Peep';
      case 'bottts':
        return 'Robot';
      case 'adventurer':
        return 'Maceracı';
      case 'fun-emoji':
        return 'Emoji';
      default:
        return style;
    }
  }
}

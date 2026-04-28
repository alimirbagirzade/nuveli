import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Renders a DiceBear avatar from the public dicebear.com API.
///
/// The avatar is fully determined by [style] + [seed] — same inputs
/// always give the same image. We render as SVG (sharp at any size)
/// with a soft circular background that matches the app palette.
///
/// DiceBear is free for unlimited use, no key required.
/// Docs: https://www.dicebear.com/styles/
class NuveliAvatar extends StatelessWidget {
  const NuveliAvatar({
    super.key,
    required this.style,
    required this.seed,
    this.size = 64,
    this.backgroundColor,
  });

  /// One of: lorelei, peep, bottts, adventurer, fun-emoji
  final String style;

  /// Any string. Same seed → same avatar deterministically.
  final String seed;

  /// Outer diameter in logical pixels.
  final double size;

  /// Background tint behind the (transparent) avatar SVG.
  /// Defaults to a soft primary tint.
  final Color? backgroundColor;

  static const _baseUrl = 'https://api.dicebear.com/7.x';

  String get _url {
    // Some DiceBear styles benefit from a transparent background so the
    // app's circular tint shows through. We override per-style here.
    final query = StringBuffer('seed=${Uri.encodeComponent(seed)}');
    query.write('&backgroundColor=transparent');
    if (style == 'lorelei' || style == 'adventurer') {
      // These styles look better with a flat radius
      query.write('&radius=50');
    }
    return '$_baseUrl/$style/svg?$query';
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary.withOpacity(0.15);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: SvgPicture.network(
          _url,
          width: size,
          height: size,
          placeholderBuilder: (_) => Center(
            child: Icon(
              Icons.person_outline,
              size: size * 0.5,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
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

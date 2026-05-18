import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/i18n/language_provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class NuveliApp extends ConsumerStatefulWidget {
  const NuveliApp({super.key});

  @override
  ConsumerState<NuveliApp> createState() => _NuveliAppState();
}

class _NuveliAppState extends ConsumerState<NuveliApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Cold start: app kapalıyken link ile açıldıysa
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Deep link initial error: $e');
    }

    // Warm start: app açıkken gelen linkler
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) => debugPrint('Deep link stream error: $err'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    // nuveli://acceptance/age-gate → /acceptance/age-gate
    // nuveli:///home → /home
    final path = uri.path.isNotEmpty ? uri.path : '/${uri.host}';
    if (path.isEmpty || path == '/') return;
    final router = ref.read(appRouterProvider);
    router.go(path);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    // ValueListenableBuilder: Riverpod'dan BAGIMSIZ
    // globalLanguageNotifier ASLA dispose olmaz
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: globalLanguageNotifier,
      builder: (context, language, _) {
        return MaterialApp.router(
          key: ValueKey('app_${language.code}'),
          title: 'Nuveli',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode.materialMode,
          scrollBehavior: const _AppScrollBehavior(),
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: kSupportedLocales,
          locale: language.locale,
        );
      },
    );
  }
}

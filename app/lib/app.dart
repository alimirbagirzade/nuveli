import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Custom scroll behavior so every Scrollable in the app accepts the
/// same set of input devices and uses bouncing physics on iOS.
///
/// Why we need this:
/// On iOS 26 (released early 2026) the simulator's input event
/// translation changed slightly — touch events sometimes register as
/// `PointerDeviceKind.unknown` instead of `touch` on the very first
/// frame after a build. Flutter's default ScrollBehavior only allows
/// scroll gestures from `touch` and `mouse`, so those `unknown` events
/// get dropped and the list looks like it can't be scrolled.
/// Adding `unknown` (plus stylus/trackpad for completeness) makes
/// every Scrollable accept input regardless of how the simulator
/// classifies the gesture.
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
    // Always use the bouncing physics (iOS-style overscroll) on every
    // Scrollable, including ones built with the default Material
    // physics. This also fixes the "viewport equals content extent"
    // edge case where Android-style ClampingScrollPhysics refuses to
    // start a drag at all.
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // Don't draw the desktop-style scrollbar — on iOS sim it can
    // intercept hover events that prevent drag gestures from starting
    // along the right edge of every list. Pure iOS apps don't draw
    // permanent scrollbars anyway.
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // Use the iOS-style overscroll bounce — no glow effect — so that
    // Material's default GlowingOverscrollIndicator (which on Android
    // wraps the child with a NotificationListener that can sometimes
    // intercept gestures) doesn't interfere with our scrolling.
    return child;
  }
}

/// Nuveli uygulamasının kök widget'ı.
class NuveliApp extends ConsumerWidget {
  const NuveliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Nuveli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      scrollBehavior: const _AppScrollBehavior(),
      routerConfig: router,
      // DIAGNOSTIC: log every pointer event we receive. This is
      // temporary — once scroll is confirmed working, remove this
      // builder and the print statements. iOS 26 simulator has a
      // documented gesture-translation regression and we need to see
      // what device kind events are actually arriving as.
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) {
            // ignore: avoid_print
            print('[POINTER DOWN] kind=${e.kind} pos=${e.position} '
                'buttons=${e.buttons}');
          },
          onPointerMove: (e) {
            if (e.delta.distance > 1.0) {
              // ignore: avoid_print
              print('[POINTER MOVE] kind=${e.kind} '
                  'delta=${e.delta} buttons=${e.buttons}');
            }
          },
          onPointerUp: (e) {
            // ignore: avoid_print
            print('[POINTER UP] kind=${e.kind}');
          },
          onPointerSignal: (e) {
            // ignore: avoid_print
            print('[POINTER SIGNAL] runtimeType=${e.runtimeType}');
          },
          onPointerPanZoomStart: (e) {
            // ignore: avoid_print
            print('[PAN ZOOM START] kind=${e.kind} (trackpad)');
          },
          onPointerPanZoomUpdate: (e) {
            if (e.panDelta.distance > 1.0) {
              // ignore: avoid_print
              print('[PAN ZOOM UPDATE] kind=${e.kind} pan=${e.panDelta}');
            }
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

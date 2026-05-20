import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_bottom_nav.dart';

/// 4 ana sekmeyi Nuveli arka planı + kalıcı bottom nav ile sarmalar.
///
/// StatefulShellRoute.indexedStack sayesinde her sekme kendi navigation
/// stack'ini korur — sekmeler arasında geçince scroll/state kaybolmaz.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: NuveliBackground(child: navigationShell),
      bottomNavigationBar: NuveliBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Aktif sekmeye tekrar basılırsa o sekmenin köküne dön
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_providers.dart';
import 'app_tabbar.dart';
import 'app_topbar.dart';
import '../../features/search/command_palette.dart';

/// Single-section shell: everything lives in one continuous vertical
/// column — top bar, then a horizontal tab strip for navigation, then the
/// page content. There is no side panel.
class AppShell extends ConsumerWidget {
  final String route;
  final String title;
  final Widget child;
  const AppShell({
    super.key,
    required this.route,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(feesDataLoadedProvider);
    final paletteOpen = ref.watch(commandPaletteOpenProvider);

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyK,
        ): () =>
            ref.read(commandPaletteOpenProvider.notifier).state = true,
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK): () =>
            ref.read(commandPaletteOpenProvider.notifier).state = true,
        LogicalKeySet(LogicalKeyboardKey.escape): () =>
            ref.read(commandPaletteOpenProvider.notifier).state = false,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, -1.0),
                    radius: 1.6,
                    colors: [
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF6E56F7).withOpacity(0.07)
                          : const Color(0xFF6E56F7).withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  AppTopbar(title: title),
                  AppTabBar(currentRoute: route),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.transparent,
                      child: child,
                    ),
                  ),
                ],
              ),
              if (paletteOpen) const CommandPalette(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FieldLayout extends StatelessWidget {
  final Widget child;

  const FieldLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = location.startsWith('/field/sync') ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (idx) {
          if (idx == 0) {
            context.go('/field/survey');
          } else {
            context.go('/field/sync');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.fileText), label: 'Report Entry'),
          NavigationDestination(icon: Icon(LucideIcons.server), label: 'Offline Queue'),
        ],
      ),
    );
  }
}

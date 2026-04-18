import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VolunteerLayout extends StatelessWidget {
  final Widget child;

  const VolunteerLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Determine selected index based on route
    int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.list), label: 'Feed'),
          NavigationDestination(icon: Icon(LucideIcons.mapPin), label: 'Map View'),
          NavigationDestination(icon: Icon(LucideIcons.checkSquare), label: 'My Tasks'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/volunteer/feed')) return 0;
    if (location.startsWith('/volunteer/map')) return 1;
    if (location.startsWith('/volunteer/tasks')) return 2;
    if (location.startsWith('/volunteer/profile')) return 3;
    return 0; // default
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/volunteer/feed');
        break;
      case 1:
        context.go('/volunteer/map');
        break;
      case 2:
        context.go('/volunteer/tasks');
        break;
      case 3:
        context.go('/volunteer/profile');
        break;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isWide ? null : AppBar(
        title: const Text('NGO Admin'),
      ),
      drawer: isWide ? null : Builder(
        builder: (ctx) => _buildDrawer(ctx, isWide),
      ),
      body: Row(
        children: [
          if (isWide) _buildDrawer(context, isWide),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isWide) {
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.shieldCheck, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.watch<AppState>().currentAdminName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Ops Center',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(context, 'Dashboard', LucideIcons.layoutDashboard, '/admin/dashboard', location, isWide),
          _buildNavItem(context, 'Heat Map', LucideIcons.map, '/admin/heatmap', location, isWide),
          _buildNavItem(context, 'Priority Control', LucideIcons.siren, '/admin/priority', location, isWide),
          _buildNavItem(context, 'Volunteers', LucideIcons.users, '/admin/volunteers', location, isWide),
          _buildNavItem(context, 'Dispatch Queue', LucideIcons.clipboardCheck, '/admin/dispatch', location, isWide),
          _buildNavItem(context, 'Campaigns', LucideIcons.megaphone, '/admin/campaigns', location, isWide),
          _buildNavItem(context, 'Ingestion Monitor', LucideIcons.database, '/admin/ingestion', location, isWide),
          _buildNavItem(context, 'Analytics', LucideIcons.barChart2, '/admin/analytics', location, isWide),
          _buildNavItem(context, 'Settings', LucideIcons.settings, '/admin/settings', location, isWide),
          const Divider(),
          _buildNavItem(context, 'Sign Out', LucideIcons.logOut, '/', location, isWide),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String path, String currentLocation, bool isWide) {
    final isSelected = currentLocation.startsWith(path);
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (!isWide) {
          Navigator.pop(context);
        }
        context.go(path);
      },
    );
  }
}

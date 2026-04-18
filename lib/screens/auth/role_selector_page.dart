import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RoleSelectorPage extends StatelessWidget {
  const RoleSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(LucideIcons.globe, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                'Smart Resource Allocation',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildRoleCard(
                context,
                title: 'NGO Admin / Coordinator',
                subtitle: 'Manage heat maps, campaigns, and dispatch',
                icon: LucideIcons.layoutDashboard,
                onTap: () => context.go('/admin/auth'),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: 'Volunteer',
                subtitle: 'Find and accept tasks based on your skills',
                icon: LucideIcons.userCheck,
                onTap: () => context.go('/volunteer/auth'),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: 'Field Worker Data Entry',
                subtitle: 'Submit reports & surveys (Offline Supported)',
                icon: LucideIcons.fileText,
                onTap: () => context.go('/field/auth'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

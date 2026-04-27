import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/models/volunteer.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class VolunteerManagementPage extends StatefulWidget {
  const VolunteerManagementPage({super.key});

  @override
  State<VolunteerManagementPage> createState() => _VolunteerManagementPageState();
}

class _VolunteerManagementPageState extends State<VolunteerManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().fetchVolunteers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final volunteers = state.volunteers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Database'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {
              // Open filter drawer
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: volunteers.length,
        itemBuilder: (context, index) {
          final vol = volunteers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(vol.status),
                child: const Icon(LucideIcons.user, color: Colors.white),
              ),
              title: Text(vol.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${vol.baseZone} • ${vol.status.name.toUpperCase()}'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: vol.skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(s, style: const TextStyle(fontSize: 10, color: AppTheme.accentBlue)),
                    )).toList(),
                  )
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.star, size: 14, color: AppTheme.foodAmber),
                      const SizedBox(width: 4),
                      Text(vol.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${vol.tasksCompleted} tasks completed', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                // Open volunteer profile bottom sheet
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(VolunteerStatus status) {
    if (status == VolunteerStatus.available) return AppTheme.healthGreen;
    if (status == VolunteerStatus.busy) return AppTheme.foodAmber;
    return Colors.grey;
  }
}

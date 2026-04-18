import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/models/need.dart';
import 'package:smart_resource_alloc/widgets/urgency_badge.dart';

class TaskDetailPage extends StatelessWidget {
  final Need task; // In a real app we would pass id and fetch from provider

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Task Details'),
            floating: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mock Map Preview Header
                Container(
                  height: 200,
                  color: Colors.grey.shade900,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.map, size: 48, color: Colors.white24),
                        const SizedBox(height: 8),
                        Text('\${task.zoneName} Zone', style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.healthGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Matched: +95% Fit', style: TextStyle(color: AppTheme.healthGreen, fontWeight: FontWeight.bold)),
                          ),
                          UrgencyBadge(score: task.urgencyScore),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(task.description, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(),
                      ),
                      
                      const Text('Required Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: task.requiredSkills.map((s) => _buildMatchedSkillChip(s)).toList(),
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.checkSquare),
                          label: const Text('Accept & Commit', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(LucideIcons.x),
                          label: const Text('Decline'),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMatchedSkillChip(String label) {
    // Assuming everything matches for demo purposes
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.healthGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.healthGreen.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.checkCircle2, size: 14, color: AppTheme.healthGreen),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.healthGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

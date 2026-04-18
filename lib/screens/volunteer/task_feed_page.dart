import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/widgets/urgency_badge.dart';

class TaskFeedPage extends StatelessWidget {
  const TaskFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Simulating volunteer matching sort by urgency
    final suggestions = List.of(state.activeNeeds)
      ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Tasks'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.filter), onPressed: () {}),
        ],
      ),
      body: suggestions.isEmpty 
          ? const Center(child: Text('No active tasks nearby!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final task = suggestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.healthGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('92% Skill Match', style: TextStyle(color: AppTheme.healthGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            UrgencyBadge(score: task.urgencyScore),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 14, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text('\${task.zoneName} (1.2 km away)', style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('View on Map'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context.push('/volunteer/task_detail', extra: task);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                                child: const Text('Accept Task'),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

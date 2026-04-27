import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/models/need.dart';
import 'package:smart_resource_alloc/models/volunteer.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class DispatchQueuePage extends StatelessWidget {
  const DispatchQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Needs that require manual dispatch (High urgency, open)
    final queue = state.activeNeeds.where((n) => n.urgencyScore >= 6 && n.urgencyScore < 8 && n.status == NeedStatus.open).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Approval Queue'),
      ),
      body: queue.isEmpty
          ? const Center(child: Text('All caught up! No pending approvals.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final need = queue[index];
                final matchedVolunteer = state.volunteers.firstWhere((v) => v.status == VolunteerStatus.available, orElse: () => state.volunteers.first);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppTheme.foodAmber.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(need.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.foodAmber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text('Score: ${need.urgencyScore}', style: const TextStyle(color: AppTheme.foodAmber, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${need.zoneName} • ${need.requiredSkills.join(", ")}', style: const TextStyle(color: Colors.white70)),
                        const Divider(height: 32),
                        const Text('Top Match from Engine:', style: TextStyle(fontSize: 12, color: Colors.white54)),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(matchedVolunteer.name[0])),
                          title: Text(matchedVolunteer.name),
                          subtitle: Text('Distance: 1.2km • Skill Match: 95%'),
                          trailing: const Text('92%', style: TextStyle(color: AppTheme.healthGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final res = await state.triggerDispatch(need.id);
                                  if (context.mounted) {
                                    if (res != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Re-ranked successfully')));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.lastError ?? 'Re-rank failed')));
                                    }
                                  }
                                },
                                child: const Text('Re-rank'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final success = await state.assignVolunteerApi(need.id, matchedVolunteer.id);
                                  if (context.mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Volunteer Dispatched')));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.lastError ?? 'Dispatch failed')));
                                    }
                                  }
                                },
                                icon: const Icon(LucideIcons.send),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.healthGreen),
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

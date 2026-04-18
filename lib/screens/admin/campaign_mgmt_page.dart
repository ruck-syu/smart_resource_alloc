import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/models/campaign.dart';
import 'package:intl/intl.dart';

class CampaignManagementPage extends StatelessWidget {
  const CampaignManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final campaigns = state.campaigns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              // Open create campaign flow
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final camp = campaigns[index];
          final isActive = camp.status == CampaignStatus.active;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          camp.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.healthGreen.withOpacity(0.2) : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          camp.status.name.toUpperCase(),
                          style: TextStyle(
                            color: isActive ? AppTheme.healthGreen : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(camp.description, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${camp.enrolledVolunteers} / ${camp.targetVolunteers} Volunteers Enrolled', style: const TextStyle(fontSize: 12)),
                      Text('${camp.progressPercentage}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: camp.progressPercentage / 100,
                    backgroundColor: Colors.white12,
                    color: AppTheme.accentBlue,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ends: ${DateFormat("MMM dd, yyyy").format(camp.endDate)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      if (isActive)
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.pause, size: 16),
                          label: const Text('Pause'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.play, size: 16),
                          label: const Text('Launch Engine'),
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

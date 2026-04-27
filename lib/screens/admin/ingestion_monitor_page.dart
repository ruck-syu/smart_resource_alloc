import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';

class DataIngestionMonitorPage extends StatelessWidget {
  const DataIngestionMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Ingestion Pipelines'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPipelineCard(context, 'Google Cloud Vision (OCR)', 'Extracting handwritten forms', PipelineStatus.healthy, '2 mins ago', 1240),
          _buildPipelineCard(context, 'REST API Sync', 'Sourcing from NGO partner DBs', PipelineStatus.syncing, 'Syncing...', 450),
          _buildPipelineCard(context, 'WhatsApp / Twilio Feed', 'Processing inbound chat reports', PipelineStatus.healthy, 'Just now', 89),
          _buildPipelineCard(context, 'CSV Batch Upload', 'Scheduled legacy data dumps', PipelineStatus.warning, 'Failed 3 hours ago', 0),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final api = context.read<AppState>().api;
              try {
                final res = await api.batchUpload(
                  [1, 2, 3], // Mock CSV bytes
                  'manual_upload.csv',
                  zone: 'all',
                );
                if (context.mounted) {
                  if (res['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV Batch Upload queued')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Upload failed')));
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload error: $e')));
                }
              }
            },
            icon: const Icon(LucideIcons.upload),
            label: const Text('Upload CSV Manually'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPipelineCard(BuildContext context, String title, String description, PipelineStatus status, String lastSync, int records) {
    Color cardColor;
    IconData statusIcon;

    switch (status) {
      case PipelineStatus.healthy:
        cardColor = AppTheme.healthGreen;
        statusIcon = LucideIcons.checkCircle;
        break;
      case PipelineStatus.warning:
        cardColor = AppTheme.urgentRed;
        statusIcon = LucideIcons.alertTriangle;
        break;
      case PipelineStatus.syncing:
        cardColor = AppTheme.accentBlue;
        statusIcon = LucideIcons.refreshCw;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cardColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: cardColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Last Sync: \$lastSync'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Records processed today: \$records', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == PipelineStatus.warning)
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.alertTriangle, color: AppTheme.urgentRed),
                        label: const Text('View Logs', style: TextStyle(color: AppTheme.urgentRed)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final api = context.read<AppState>().api;
                        try {
                          final res = await api.ingestData({
                            'sourceType': 'manual_sync',
                            'metadata': {'pipeline': title}
                          });
                          if (context.mounted) {
                            if (res['success'] == true) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Force Sync queued for $title')));
                            } else {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Sync failed')));
                            }
                          }
                        } catch (e) {
                           if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync error: $e')));
                           }
                        }
                      },
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Force Sync'),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

enum PipelineStatus { healthy, warning, syncing }

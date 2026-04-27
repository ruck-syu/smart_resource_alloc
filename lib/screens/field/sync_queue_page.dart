import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/services/offline_storage_service.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class SyncQueuePage extends StatefulWidget {
  const SyncQueuePage({super.key});

  @override
  State<SyncQueuePage> createState() => _SyncQueuePageState();
}

class _SyncQueuePageState extends State<SyncQueuePage> {
  List<Map<dynamic, dynamic>> _reports = [];
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reports = OfflineStorageService.getPendingReports();
    });
  }

  void _executeSync() async {
    setState(() {
      _isSyncing = true;
    });
    
    final api = context.read<AppState>().api;
    bool hasError = false;

    final reportsMap = OfflineStorageService.getPendingReportsWithKeys();

    for (var entry in reportsMap.entries) {
      final key = entry.key;
      final report = entry.value;
      try {
        final res = await api.ingestData({
          'sourceType': 'offline_sync',
          'metadata': {'timestamp': report['timestamp'], 'title': report['title']}
        });
        if (res['success'] == true) {
          await OfflineStorageService.markAsSynced(key);
        } else {
          hasError = true;
          await OfflineStorageService.markAsFailed(key, res['error'] ?? 'Unknown API error');
        }
      } catch (e) {
        hasError = true;
        await OfflineStorageService.markAsFailed(key, e.toString());
      }
    }
    
    if (!hasError) {
      await OfflineStorageService.clearUploadedReports();
    }
    
    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
      _loadReports();
      if (!hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All pending data successfully pushed to cloud!'), backgroundColor: AppTheme.healthGreen)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Some reports failed to sync. Please try again later.'), backgroundColor: AppTheme.urgentRed)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Queue'),
        actions: [
          if (_reports.isNotEmpty)
            TextButton.icon(
              onPressed: _isSyncing ? null : _executeSync,
              icon: _isSyncing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(LucideIcons.uploadCloud, color: Colors.white),
              label: Text(_isSyncing ? 'Syncing...' : 'Sync All', style: const TextStyle(color: Colors.white)),
            ),
          IconButton(icon: const Icon(LucideIcons.logOut, color: Colors.white70), onPressed: () => context.go('/')),
          const SizedBox(width: 8),
        ],
      ),
      body: _reports.isEmpty 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.cloudOff, size: 60, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Queue is empty', style: TextStyle(fontSize: 18, color: Colors.white54)),
                  Text('All field data is fully synced', style: TextStyle(color: Colors.white30)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Icon(LucideIcons.fileText, color: Colors.white54),
                    ),
                    title: Text(report['title']),
                    subtitle: Text('Added: ${report['timestamp'].toString().substring(0, 16).replaceFirst('T', ' ')}'),
                    trailing: const Chip(
                      label: Text('Pending'),
                      backgroundColor: Colors.white10,
                      side: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/widgets/heat_map_widget.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class HeatMapDetailPage extends StatefulWidget {
  const HeatMapDetailPage({super.key});

  @override
  State<HeatMapDetailPage> createState() => _HeatMapDetailPageState();
}

class _HeatMapDetailPageState extends State<HeatMapDetailPage> {
  bool _showNeeds = true;
  bool _showVolunteers = true;
  bool _showCampaigns = false;
  double _timeRange = 24; // Hours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Heat Map'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            tooltip: 'Export Snapshot',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map snapshot exported')),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Full Screen Map
          const HeatMapWidget(interactive: true),
          
          // Layer Controls Overlays (Left)
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              color: AppTheme.surfaceDark.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Map Layers', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildSwitch('Need Hotspots', _showNeeds, (v) => setState(() => _showNeeds = v)),
                    _buildSwitch('Volunteer Positions', _showVolunteers, (v) => setState(() => _showVolunteers = v)),
                    _buildSwitch('Campaign Coverage', _showCampaigns, (v) => setState(() => _showCampaigns = v)),
                  ],
                ),
              ),
            ),
          ),

          // Time Range Slider Overlay (Bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              color: AppTheme.surfaceDark.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Time Range:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _timeRange,
                        min: 1,
                        max: 72,
                        divisions: 71,
                        label: '${_timeRange.round()} hours',
                        activeColor: AppTheme.accentBlue,
                        onChanged: (v) => setState(() => _timeRange = v),
                      ),
                    ),
                    Text('${_timeRange.round()}h', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentBlue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(title, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
      ],
    );
  }
}

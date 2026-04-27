import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/widgets/urgency_badge.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/models/need.dart';

class PriorityControlPage extends StatefulWidget {
  const PriorityControlPage({super.key});

  @override
  State<PriorityControlPage> createState() => _PriorityControlPageState();
}

class _PriorityControlPageState extends State<PriorityControlPage> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().fetchNeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Sort needs by urgency score descending
    final needs = List<Need>.from(state.activeNeeds)
      ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Priority Control Panel'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              }),
            ),
        ],
      ),
      body: needs.isEmpty
          ? const Center(child: Text('No active needs at the moment.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: needs.length,
              itemBuilder: (context, index) {
                final need = needs[index];
                final isSelected = _selectedIds.contains(need.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected ? AppTheme.accentBlue : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onLongPress: () {
                      setState(() {
                        _isSelectionMode = true;
                        _selectedIds.add(need.id);
                      });
                    },
                    onTap: () {
                      if (_isSelectionMode) {
                        setState(() {
                          if (isSelected) _selectedIds.remove(need.id);
                          else _selectedIds.add(need.id);
                        });
                      } else {
                        // Open Need details
                      }
                    },
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) _selectedIds.add(need.id);
                                else _selectedIds.remove(need.id);
                              });
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: AppTheme.getUrgencyColor(need.urgencyScore).withOpacity(0.2),
                            child: Icon(_getCategoryIcon(need.category), color: AppTheme.getUrgencyColor(need.urgencyScore)),
                          ),
                    title: Text(need.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${need.zoneName} • ${need.status.name.toUpperCase()}'),
                        if (need.assignedVolunteerId != null) ...[
                           const SizedBox(height: 4),
                           Text('Assigned to: ${need.assignedVolunteerId}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ]
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        UrgencyBadge(score: need.urgencyScore),
                        const SizedBox(height: 4),
                        if (need.urgencyScore >= 8 && need.status == NeedStatus.open)
                          const Text('Awaiting Dispatch', style: TextStyle(color: AppTheme.urgentRed, fontSize: 10, fontWeight: FontWeight.bold))
                      ],
                    ),
                    isThreeLine: need.assignedVolunteerId != null,
                  ),
                );
              },
            ),
      floatingActionButton: _isSelectionMode && _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // Bulk action logic
                for (var id in _selectedIds) {
                  state.markNeedResolved(id);
                }
                setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Needs marked as resolved.')),
                );
              },
              backgroundColor: AppTheme.healthGreen,
              icon: const Icon(LucideIcons.checkCircle),
              label: Text('Resolve (${_selectedIds.length})'),
            )
          : FloatingActionButton(
              onPressed: () => _showCreateNeedDialog(context),
              backgroundColor: AppTheme.accentBlue,
              child: const Icon(LucideIcons.plus),
            ),
    );
  }

  void _showCreateNeedDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final zoneCtrl = TextEditingController(text: 'Central Hub');
    final skillsCtrl = TextEditingController();
    double urgency = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create New Need'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: zoneCtrl, decoration: const InputDecoration(labelText: 'Zone (e.g., Central Hub)')),
                TextField(controller: skillsCtrl, decoration: const InputDecoration(labelText: 'Required Skills (comma separated)')),
                const SizedBox(height: 16),
                const Text('Urgency Score (1-10)'),
                Slider(
                  value: urgency,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: urgency.round().toString(),
                  onChanged: (val) => setDialogState(() => urgency = val),
                  activeColor: AppTheme.getUrgencyColor(urgency.round()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final skills = skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                
                final success = await context.read<AppState>().createNeed({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'zone': zoneCtrl.text,
                  'category': 'disaster_relief', // Defaulting for quick creation
                  'urgencyScore': urgency.round(),
                  'location': {'latitude': 12.9716, 'longitude': 77.5946},
                  'requiredSkills': skills,
                  'volunteersNeeded': 1,
                });
                
                if (mounted && ctx.mounted) {
                  Navigator.pop(ctx);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Need created successfully!')));
                    context.read<AppState>().fetchNeeds();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create need.')));
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NeedCategory cat) {
    switch(cat) {
      case NeedCategory.health: return LucideIcons.activity;
      case NeedCategory.education: return LucideIcons.book;
      case NeedCategory.food: return LucideIcons.utensils;
      case NeedCategory.shelter: return LucideIcons.home;
      case NeedCategory.disasterRelief: return LucideIcons.alertTriangle;
      case NeedCategory.sanitation: return LucideIcons.trash2;
      case NeedCategory.bloodDonation: return LucideIcons.droplets;
      case NeedCategory.environment: return LucideIcons.leaf;
      case NeedCategory.blood: return LucideIcons.droplets;
      case NeedCategory.rescue: return LucideIcons.lifeBuoy;
      case NeedCategory.other: return LucideIcons.helpCircle;
    }
  }
}

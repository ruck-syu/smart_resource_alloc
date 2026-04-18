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
          : null,
    );
  }

  IconData _getCategoryIcon(NeedCategory cat) {
    switch(cat) {
      case NeedCategory.health: return LucideIcons.activity;
      case NeedCategory.food: return LucideIcons.utensils;
      case NeedCategory.shelter: return LucideIcons.home;
      case NeedCategory.blood: return LucideIcons.droplets;
      case NeedCategory.rescue: return LucideIcons.lifeBuoy;
    }
  }
}

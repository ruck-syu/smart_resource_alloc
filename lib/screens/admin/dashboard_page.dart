import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/widgets/heat_map_widget.dart';
import 'package:smart_resource_alloc/widgets/stat_card.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Live Dashboard'),
            floating: true,
            actions: [
              IconButton(
                icon: const Badge(
                  label: Text('3'),
                  child: Icon(LucideIcons.bell),
                ),
                onPressed: () {},
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          StatCard(
                            title: 'Active Needs',
                            value: '${state.activeNeeds.length}',
                            icon: LucideIcons.activity,
                            color: AppTheme.accentBlue,
                            subtitle: '${state.criticalNeeds.length} Critical',
                          ),
                          StatCard(
                            title: 'Volunteers Deployed',
                            value: '${state.activeVolunteersCount}',
                            icon: LucideIcons.users,
                            color: AppTheme.healthGreen,
                            subtitle: 'Out of ${state.volunteers.length} total',
                          ),
                          StatCard(
                            title: 'Pending Approvals',
                            value: '5',
                            icon: LucideIcons.clipboardCheck,
                            color: AppTheme.foodAmber,
                            subtitle: 'Needs review',
                          ),
                          StatCard(
                            title: 'Active Campaigns',
                            value: '${state.campaigns.length}',
                            icon: LucideIcons.megaphone,
                            color: AppTheme.shelterIndigo,
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 24),
                  
                  // Heat Map Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live AI Urgency Heat Map',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(LucideIcons.maximize2, size: 16),
                        label: const Text('Expand Map'),
                        onPressed: () {},
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Map Container
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const HeatMapWidget(interactive: false),
                        // Overlay Filters
                        Positioned(
                          top: 16,
                          left: 16,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All', true),
                                const SizedBox(width: 8),
                                _buildFilterChip('Health', false),
                                const SizedBox(width: 8),
                                _buildFilterChip('Food', false),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: Colors.black54,
    );
  }
}

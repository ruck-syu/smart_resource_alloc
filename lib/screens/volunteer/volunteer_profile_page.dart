import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class VolunteerProfilePage extends StatefulWidget {
  const VolunteerProfilePage({super.key});

  @override
  State<VolunteerProfilePage> createState() => _VolunteerProfilePageState();
}

class _VolunteerProfilePageState extends State<VolunteerProfilePage> {
  bool _onDuty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/volunteer/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildDutyToggle(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          const Text('My Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSkillChip('Medical Professional'),
              _buildSkillChip('First Aid'),
              _buildSkillChip('Logistics'),
              _buildSkillChip('Community Outreach'),
              ActionChip(
                label: const Text('+ Add Skill'),
                onPressed: () {},
                backgroundColor: Colors.white10,
              )
            ],
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              context.go('/');
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.redAccent.withOpacity(0.1),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final state = context.watch<AppState>();

    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.accentBlue,
          child: Icon(LucideIcons.user, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.currentVolunteerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Base: ${state.currentVolunteerZone}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 16, color: AppTheme.foodAmber),
                  const SizedBox(width: 4),
                  const Text('4.9 Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDutyToggle() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _onDuty ? AppTheme.healthGreen : Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: const Text('Availability Status', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_onDuty ? 'On Duty. Engine can match you.' : 'Off Duty. You will not receive alerts.'),
        value: _onDuty,
        activeColor: AppTheme.healthGreen,
        onChanged: (v) => setState(() => _onDuty = v),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBox('Tasks Logged', '24'),
        const SizedBox(width: 16),
        _buildStatBox('Reliability', '98%'),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.accentBlue.withOpacity(0.2),
      labelStyle: const TextStyle(color: AppTheme.accentBlue),
      side: BorderSide.none,
    );
  }
}

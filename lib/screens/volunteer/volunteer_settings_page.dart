import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class VolunteerSettingsPage extends StatefulWidget {
  const VolunteerSettingsPage({super.key});

  @override
  State<VolunteerSettingsPage> createState() => _VolunteerSettingsPageState();
}

class _VolunteerSettingsPageState extends State<VolunteerSettingsPage> {
  late TextEditingController _nameController;
  late String _selectedZone;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _nameController = TextEditingController(text: state.currentVolunteerName);
    _selectedZone = state.currentVolunteerZone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.accentBlue,
                    child: Icon(LucideIcons.user, size: 50, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.healthGreen,
                      child: Icon(LucideIcons.camera, size: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                prefixIcon: const Icon(LucideIcons.user, color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Primary Base Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedZone,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                prefixIcon: const Icon(LucideIcons.mapPin, color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: <String>[
                'Koramangala Zone',
                'Indiranagar Hub',
                'Whitefield Sector',
                'Jayanagar Central',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (v) {
                setState(() { _selectedZone = v!; });
              },
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AppState>().updateVolunteerProfile(
                    _nameController.text,
                    _selectedZone,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile changes saved successfully!')),
                  );
                  context.pop();
                },
                icon: const Icon(LucideIcons.save),
                label: const Text('Save Profile Update', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.healthGreen),
              ),
            )
          ],
        ),
      ),
    );
  }
}

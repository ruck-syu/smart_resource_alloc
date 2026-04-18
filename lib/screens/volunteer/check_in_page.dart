import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  String _outcome = 'Success - Request Resolved';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Reporting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.mapPin, color: AppTheme.accentBlue),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GPS Auto-Captured', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Lat: 12.9716, Lng: 77.5946 (Accuracy: 4m)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.checkCircle, color: AppTheme.healthGreen),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Action Outcome', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _outcome,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: <String>[
                'Success - Request Resolved',
                'Partial - Needs Follow Up',
                'Failed - Nobody Present',
                'Failed - Insufficient Resources',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (v) {
                setState(() { _outcome = v!; });
              },
            ),
            const SizedBox(height: 24),
            const Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.camera),
                    label: const Text('Add Photo'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                     onPressed: () {},
                     icon: const Icon(LucideIcons.mic),
                     label: const Text('Voice Note'),
                     style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  )
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Field Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter any additional details...',
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Process ML Outcome Feedback implicitly here
                },
                icon: const Icon(LucideIcons.uploadCloud),
                label: const Text('Submit Report & Feed Model', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.healthGreen),
              ),
            )
          ],
        ),
      ),
    );
  }
}

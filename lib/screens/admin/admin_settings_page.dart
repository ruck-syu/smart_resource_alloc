import 'package:flutter/material.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  double _urgencyWeight = 0.4;
  double _skillWeight = 0.3;
  double _proximityWeight = 0.2;
  double _availabilityWeight = 0.1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorithm Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Matching Engine Weights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Adjust the neural matching algorithm weights manually. Ensure total equals 1.0', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          _buildWeightSlider('Urgency Fit', _urgencyWeight, AppTheme.urgentRed, (v) => setState(() => _urgencyWeight = v)),
          _buildWeightSlider('Skill Match', _skillWeight, AppTheme.healthGreen, (v) => setState(() => _skillWeight = v)),
          _buildWeightSlider('Proximity', _proximityWeight, AppTheme.accentBlue, (v) => setState(() => _proximityWeight = v)),
          _buildWeightSlider('Availability', _availabilityWeight, AppTheme.foodAmber, (v) => setState(() => _availabilityWeight = v)),
          const SizedBox(height: 16),
          _buildTotalIndicator(),
          const Divider(height: 48),
          const Text('Autonomous Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-dispatch Critical Needs'),
            subtitle: const Text('Skip human approval for needs scoring 8-10'),
            value: true,
            onChanged: (v) {},
            activeColor: AppTheme.accentBlue,
          ),
          SwitchListTile(
            title: const Text('Predictive Re-routing'),
            subtitle: const Text('Re-route busy volunteers if new critical need opens nearby'),
            value: false,
            onChanged: (v) {},
            activeColor: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 1,
          divisions: 20,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTotalIndicator() {
    double total = _urgencyWeight + _skillWeight + _proximityWeight + _availabilityWeight;
    bool isValid = (total - 1.0).abs() < 0.01;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Weights:'),
        Text(
          total.toStringAsFixed(2),
          style: TextStyle(
            color: isValid ? AppTheme.healthGreen : AppTheme.urgentRed,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/services/offline_storage_service.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({super.key});

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  String _selectedCategory = 'Health & Medical';
  double _severity = 5.0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: 'Requesting GPS coordinate...');
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _locationController.text = 'Location services are disabled.'; _isLoadingLocation = false; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() { _locationController.text = 'Location permissions denied.'; _isLoadingLocation = false; });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _locationController.text = 'Location permissions permanently denied.'; _isLoadingLocation = false; });
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      if (mounted) {
        setState(() {
          _locationController.text = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _locationController.text = 'Failed to get location'; _isLoadingLocation = false; });
    }
  }

  void _saveOffline() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title.')));
      return;
    }

    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'category': _selectedCategory,
      'severity': _severity,
      'location': _locationController.text,
      'attachments': 1 // representing a mock image attached
    };

    await OfflineStorageService.saveReport(data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report saved to Offline Queue!'), backgroundColor: AppTheme.healthGreen));
      _titleController.clear();
      _descController.clear();
      setState(() {
        _severity = 5.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Data Entry'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.wifiOff), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.logOut, color: Colors.white70), onPressed: () => context.go('/')),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.foodAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(LucideIcons.radioTower, color: AppTheme.foodAmber),
                  SizedBox(width: 12),
                  Expanded(child: Text('Offline Mode Active. Surveys will sync when connectivity implies.', style: TextStyle(color: AppTheme.foodAmber, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Need Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                hintText: 'e.g., Waterlogging in Sector 4',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ['Health & Medical', 'Food & Ration', 'Shelter', 'Logistics', 'Rescue']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 24),
            const Text('Observed Severity (1-10)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Low', style: TextStyle(color: Colors.white54)),
                Expanded(
                  child: Slider(
                    value: _severity,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _severity.round().toString(),
                    activeColor: AppTheme.getUrgencyColor(_severity.round()),
                    onChanged: (v) => setState(() => _severity = v),
                  ),
                ),
                const Text('Critical', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Auto-Captured GPS Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              readOnly: true,
              style: TextStyle(color: _isLoadingLocation ? AppTheme.foodAmber : AppTheme.healthGreen),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                prefixIcon: _isLoadingLocation 
                    ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.foodAmber)))
                    : const Icon(LucideIcons.mapPin, color: AppTheme.healthGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Description & Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                hintText: 'Provide contextual detail...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.camera),
                    label: const Text('Capture Form/OCR'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveOffline,
                icon: const Icon(LucideIcons.save),
                label: const Text('Save Offline & Queue Sync', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

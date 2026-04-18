import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/data/mock_data.dart';

class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final needs = context.watch<AppState>().activeNeeds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Needs'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: MockData.bangaloreCenter,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.antigravity.smart_resource_alloc',
          ),
          MarkerLayer(
            markers: needs.map((need) {
              return Marker(
                point: need.location,
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    _showNeedModal(context, need);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on,
                      color: AppTheme.getUrgencyColor(need.urgencyScore),
                      size: 36,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _showNeedModal(BuildContext context, need) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(need.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(need.description, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('Accept & Request Route'),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/data/mock_data.dart';

class HeatMapWidget extends StatelessWidget {
  final bool interactive;
  
  const HeatMapWidget({super.key, this.interactive = true});

  @override
  Widget build(BuildContext context) {
    final needs = context.watch<AppState>().activeNeeds;

    return FlutterMap(
      options: MapOptions(
        initialCenter: MockData.bangaloreCenter,
        initialZoom: 12.0,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.antigravity.smart_resource_alloc',
          // Use a dark mode tile filter if possible, or leave default OSM. 
          // For now using default OSM tiles.
        ),
        CircleLayer(
          circles: needs.map((need) {
            return CircleMarker(
              point: need.location,
              color: AppTheme.getUrgencyColor(need.urgencyScore).withOpacity(0.4),
              borderStrokeWidth: 2,
              borderColor: AppTheme.getUrgencyColor(need.urgencyScore),
              radius: need.urgencyScore * 40.0, // Scale radius by urgency
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: needs.map((need) {
            return Marker(
              point: need.location,
              width: 40,
              height: 40,
              child: Icon(
                Icons.location_on,
                color: AppTheme.getUrgencyColor(need.urgencyScore),
                size: 30,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

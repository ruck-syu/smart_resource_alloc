import 'package:flutter/material.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class UrgencyBadge extends StatelessWidget {
  final int score;

  const UrgencyBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.getUrgencyColor(score);
    String label = 'Normal';
    
    if (score >= 8) label = 'Critical';
    else if (score >= 6) label = 'High';
    else if (score >= 4) label = 'Moderate';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$score/10 $label',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

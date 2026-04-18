import 'package:latlong2/latlong.dart';

enum NeedCategory { health, food, shelter, blood, rescue }
enum UrgencyLevel { normal, moderate, high, critical }
enum NeedStatus { open, inProgress, resolved }

class Need {
  final String id;
  final String title;
  final String description;
  final NeedCategory category;
  final int urgencyScore; // 1-10
  final LatLng location;
  final String zoneName;
  final NeedStatus status;
  final DateTime reportedAt;
  final List<String> requiredSkills;
  final String? assignedVolunteerId;

  Need({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgencyScore,
    required this.location,
    required this.zoneName,
    this.status = NeedStatus.open,
    required this.reportedAt,
    required this.requiredSkills,
    this.assignedVolunteerId,
  });

  UrgencyLevel get urgencyLevel {
    if (urgencyScore >= 8) return UrgencyLevel.critical;
    if (urgencyScore >= 6) return UrgencyLevel.high;
    if (urgencyScore >= 4) return UrgencyLevel.moderate;
    return UrgencyLevel.normal;
  }
}

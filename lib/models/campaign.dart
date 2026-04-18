import 'package:latlong2/latlong.dart';

enum CampaignStatus { planning, active, paused, completed }

class Campaign {
  final String id;
  final String title;
  final String description;
  final String targetZone;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> requiredSkills;
  final int targetVolunteers;
  final int enrolledVolunteers;
  final int progressPercentage;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.targetZone,
    this.status = CampaignStatus.planning,
    required this.startDate,
    required this.endDate,
    required this.requiredSkills,
    required this.targetVolunteers,
    this.enrolledVolunteers = 0,
    this.progressPercentage = 0,
  });
}

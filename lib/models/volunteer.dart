import 'package:latlong2/latlong.dart';

enum VolunteerStatus { available, busy, offline }

class Volunteer {
  final String id;
  final String name;
  final String profileImageUrl;
  final List<String> skills;
  final VolunteerStatus status;
  final LatLng lastKnownLocation;
  final String baseZone;
  final double rating; // 1.0 - 5.0
  final int tasksCompleted;
  final double reliabilityScore; // 0.0 - 1.0

  Volunteer({
    required this.id,
    required this.name,
    this.profileImageUrl = '',
    required this.skills,
    this.status = VolunteerStatus.offline,
    required this.lastKnownLocation,
    required this.baseZone,
    this.rating = 5.0,
    this.tasksCompleted = 0,
    this.reliabilityScore = 1.0,
  });
}

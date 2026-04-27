import 'package:latlong2/latlong.dart';

enum VolunteerStatus { available, busy, offline }

class Volunteer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;
  final List<String> skills;
  final VolunteerStatus status;
  final LatLng lastKnownLocation;
  final String baseZone;
  final String geohash;
  final String availability; // "weekdays"|"weekends"|"full_time"|"flexible"
  final int availableHours;
  final double rating; // 1.0 - 5.0
  final int tasksCompleted;
  final double reliabilityScore; // 0.0 - 1.0
  final String? fcmToken;
  final String? organizationId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Volunteer({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.profileImageUrl = '',
    required this.skills,
    this.status = VolunteerStatus.offline,
    required this.lastKnownLocation,
    required this.baseZone,
    this.geohash = '',
    this.availability = 'flexible',
    this.availableHours = 0,
    this.rating = 5.0,
    this.tasksCompleted = 0,
    this.reliabilityScore = 1.0,
    this.fcmToken,
    this.organizationId,
    this.createdAt,
    this.updatedAt,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    double lat = 0.0;
    double lng = 0.0;
    if (loc != null) {
      lat = (loc['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (loc['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    return Volunteer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: _parseStatus(json['status']),
      lastKnownLocation: LatLng(lat, lng),
      baseZone: json['geohash'] ?? json['zone'] ?? '',
      geohash: json['geohash'] ?? '',
      availability: json['availability'] ?? 'flexible',
      availableHours: json['availableHours'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      tasksCompleted: json['totalTasksCompleted'] ?? 0,
      reliabilityScore: 1.0,
      fcmToken: json['fcmToken'],
      organizationId: json['organizationId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'location': {
          'latitude': lastKnownLocation.latitude,
          'longitude': lastKnownLocation.longitude,
        },
        'skills': skills,
        'availability': availability,
        'availableHours': availableHours,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (organizationId != null) 'organizationId': organizationId,
      };

  static VolunteerStatus _parseStatus(dynamic s) {
    if (s == null) return VolunteerStatus.offline;
    final str = s.toString().toLowerCase();
    if (str == 'active' || str == 'available') return VolunteerStatus.available;
    if (str == 'busy') return VolunteerStatus.busy;
    return VolunteerStatus.offline;
  }

  String get apiStatus {
    switch (status) {
      case VolunteerStatus.available:
        return 'active';
      case VolunteerStatus.busy:
        return 'busy';
      case VolunteerStatus.offline:
        return 'inactive';
    }
  }

  Volunteer copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? skills,
    VolunteerStatus? status,
    LatLng? lastKnownLocation,
    String? baseZone,
    String? availability,
    int? availableHours,
    double? rating,
    int? tasksCompleted,
    String? fcmToken,
  }) {
    return Volunteer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl,
      skills: skills ?? this.skills,
      status: status ?? this.status,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      baseZone: baseZone ?? this.baseZone,
      geohash: geohash,
      availability: availability ?? this.availability,
      availableHours: availableHours ?? this.availableHours,
      rating: rating ?? this.rating,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      reliabilityScore: reliabilityScore,
      fcmToken: fcmToken ?? this.fcmToken,
      organizationId: organizationId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

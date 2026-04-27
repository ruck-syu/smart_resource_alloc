import 'package:latlong2/latlong.dart';

enum NeedCategory { health, education, food, shelter, disasterRelief, sanitation, bloodDonation, environment, blood, rescue, other }
enum UrgencyLevel { normal, moderate, high, critical }
enum NeedStatus { open, inProgress, resolved, closed }

class Need {
  final String id;
  final String title;
  final String description;
  final NeedCategory category;
  final String? subcategory;
  final int urgencyScore; // 1-10
  final LatLng location;
  final String geohash;
  final String zoneName;
  final NeedStatus status;
  final DateTime reportedAt;
  final List<String> requiredSkills;
  final int volunteersNeeded;
  final int volunteersAssigned;
  final String? assignedVolunteerId;
  final String? reportedBy;
  final String? sourceType;
  final String? rawDataRef;
  final DateTime? updatedAt;

  Need({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.urgencyScore,
    required this.location,
    this.geohash = '',
    required this.zoneName,
    this.status = NeedStatus.open,
    required this.reportedAt,
    required this.requiredSkills,
    this.volunteersNeeded = 1,
    this.volunteersAssigned = 0,
    this.assignedVolunteerId,
    this.reportedBy,
    this.sourceType,
    this.rawDataRef,
    this.updatedAt,
  });

  UrgencyLevel get urgencyLevel {
    if (urgencyScore >= 8) return UrgencyLevel.critical;
    if (urgencyScore >= 6) return UrgencyLevel.high;
    if (urgencyScore >= 4) return UrgencyLevel.moderate;
    return UrgencyLevel.normal;
  }

  factory Need.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    double lat = 0.0;
    double lng = 0.0;
    if (loc != null) {
      lat = (loc['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (loc['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    return Need(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategory(json['category']),
      subcategory: json['subcategory'],
      urgencyScore: json['urgencyScore'] ?? 5,
      location: LatLng(lat, lng),
      geohash: json['geohash'] ?? '',
      zoneName: json['zone'] ?? '',
      status: _parseStatus(json['status']),
      reportedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      volunteersNeeded: json['volunteersNeeded'] ?? 1,
      volunteersAssigned: json['volunteersAssigned'] ?? 0,
      assignedVolunteerId: json['assignedVolunteerId'],
      reportedBy: json['reportedBy'],
      sourceType: json['sourceType'],
      rawDataRef: json['rawDataRef'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': _categoryToString(category),
        if (subcategory != null) 'subcategory': subcategory,
        'urgencyScore': urgencyScore,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'zone': zoneName,
        'requiredSkills': requiredSkills,
        'volunteersNeeded': volunteersNeeded,
        if (sourceType != null) 'sourceType': sourceType,
      };

  static NeedCategory _parseCategory(dynamic cat) {
    if (cat == null) return NeedCategory.other;
    final s = cat.toString().toLowerCase();
    switch (s) {
      case 'health':
        return NeedCategory.health;
      case 'education':
        return NeedCategory.education;
      case 'food':
        return NeedCategory.food;
      case 'shelter':
        return NeedCategory.shelter;
      case 'disaster_relief':
        return NeedCategory.disasterRelief;
      case 'sanitation':
        return NeedCategory.sanitation;
      case 'blood_donation':
      case 'blood':
        return NeedCategory.bloodDonation;
      case 'environment':
        return NeedCategory.environment;
      case 'rescue':
        return NeedCategory.rescue;
      default:
        return NeedCategory.other;
    }
  }

  static String _categoryToString(NeedCategory cat) {
    switch (cat) {
      case NeedCategory.health:
        return 'health';
      case NeedCategory.education:
        return 'education';
      case NeedCategory.food:
        return 'food';
      case NeedCategory.shelter:
        return 'shelter';
      case NeedCategory.disasterRelief:
        return 'disaster_relief';
      case NeedCategory.sanitation:
        return 'sanitation';
      case NeedCategory.bloodDonation:
        return 'blood_donation';
      case NeedCategory.blood:
        return 'blood_donation';
      case NeedCategory.environment:
        return 'environment';
      case NeedCategory.rescue:
        return 'disaster_relief';
      case NeedCategory.other:
        return 'other';
    }
  }

  static NeedStatus _parseStatus(dynamic s) {
    if (s == null) return NeedStatus.open;
    final str = s.toString().toLowerCase();
    switch (str) {
      case 'active':
      case 'open':
        return NeedStatus.open;
      case 'in_progress':
      case 'inprogress':
        return NeedStatus.inProgress;
      case 'resolved':
        return NeedStatus.resolved;
      case 'closed':
        return NeedStatus.closed;
      default:
        return NeedStatus.open;
    }
  }

  Need copyWith({
    String? title,
    String? description,
    int? urgencyScore,
    NeedStatus? status,
    String? assignedVolunteerId,
    int? volunteersAssigned,
  }) {
    return Need(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category,
      subcategory: subcategory,
      urgencyScore: urgencyScore ?? this.urgencyScore,
      location: location,
      geohash: geohash,
      zoneName: zoneName,
      status: status ?? this.status,
      reportedAt: reportedAt,
      requiredSkills: requiredSkills,
      volunteersNeeded: volunteersNeeded,
      volunteersAssigned: volunteersAssigned ?? this.volunteersAssigned,
      assignedVolunteerId: assignedVolunteerId ?? this.assignedVolunteerId,
      reportedBy: reportedBy,
      sourceType: sourceType,
      rawDataRef: rawDataRef,
      updatedAt: DateTime.now(),
    );
  }
}

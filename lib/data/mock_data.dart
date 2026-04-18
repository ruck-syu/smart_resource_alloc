import 'package:latlong2/latlong.dart';
import 'package:smart_resource_alloc/models/need.dart';
import 'package:smart_resource_alloc/models/volunteer.dart';
import 'package:smart_resource_alloc/models/campaign.dart';

class MockData {
  // Bangalore Center
  static final LatLng bangaloreCenter = const LatLng(12.9716, 77.5946);
  
  static final List<String> zones = [
    'Indiranagar', 'Koramangala', 'Whitefield', 'Jayanagar',
    'Malleswaram', 'HSR Layout', 'BTM Layout', 'JP Nagar'
  ];

  static final List<Need> needs = [
    Need(
      id: 'n1',
      title: 'Dengue Outbreak Support',
      description: 'Multiple dengue cases reported. Need volunteers for awareness and stagnant water clearing.',
      category: NeedCategory.health,
      urgencyScore: 9,
      location: const LatLng(12.9784, 77.6408), // Indiranagar area
      zoneName: 'Indiranagar',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
      requiredSkills: ['Medical', 'Community Outreach'],
    ),
    Need(
      id: 'n2',
      title: 'Emergency Blood Requirement - O+',
      description: 'Urgent blood requirement for accident victim at Manipal Hospital.',
      category: NeedCategory.blood,
      urgencyScore: 10,
      location: const LatLng(12.9591, 77.6465), // near Manipal
      zoneName: 'Indiranagar',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      requiredSkills: ['Blood Donor'],
    ),
    Need(
      id: 'n3',
      title: 'Flood Relief - Ration Distribution',
      description: 'Recent heavy rains have flooded low-lying areas. Need volunteers to distribute dry rations.',
      category: NeedCategory.food,
      urgencyScore: 7,
      location: const LatLng(12.9121, 77.6446), // HSR Layout
      zoneName: 'HSR Layout',
      reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
      requiredSkills: ['Logistics', 'Physical Labour'],
      status: NeedStatus.inProgress,
      assignedVolunteerId: 'v1',
    ),
    Need(
      id: 'n4',
      title: 'Night Shelter Setup',
      description: 'Temporary night shelter needed for displaced workers.',
      category: NeedCategory.shelter,
      urgencyScore: 5,
      location: const LatLng(12.9250, 77.5938), // Jayanagar
      zoneName: 'Jayanagar',
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      requiredSkills: ['Construction', 'Coordination'],
    ),
    Need(
      id: 'n5',
      title: 'Community Kitchen Assistance',
      description: 'Volunteers required to help cook and pack 500 meals for distribution.',
      category: NeedCategory.food,
      urgencyScore: 4,
      location: const LatLng(12.9352, 77.6245), // Koramangala
      zoneName: 'Koramangala',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
      requiredSkills: ['Cooking', 'Packing'],
    ),
  ];

  static final List<Volunteer> volunteers = [
    Volunteer(
      id: 'v1',
      name: 'Rahul Sharma',
      skills: ['Logistics', 'Physical Labour', 'First Aid'],
      status: VolunteerStatus.busy,
      lastKnownLocation: const LatLng(12.9125, 77.6450), // near HSR
      baseZone: 'HSR Layout',
      rating: 4.8,
      tasksCompleted: 42,
    ),
    Volunteer(
      id: 'v2',
      name: 'Priya Patel',
      skills: ['Medical', 'Blood Donor'],
      status: VolunteerStatus.available,
      lastKnownLocation: const LatLng(12.9750, 77.6400),
      baseZone: 'Indiranagar',
      rating: 4.9,
      tasksCompleted: 15,
    ),
    Volunteer(
      id: 'v3',
      name: 'Amit Kumar',
      skills: ['Cooking', 'Community Outreach'],
      status: VolunteerStatus.available,
      lastKnownLocation: const LatLng(12.9300, 77.6200),
      baseZone: 'Koramangala',
      rating: 4.5,
      tasksCompleted: 28,
    ),
  ];

  static final List<Campaign> campaigns = [
    Campaign(
      id: 'c1',
      title: 'Monsoon Preparedness Drive',
      description: 'City-wide campaign to clear drains and educate on water-borne diseases ahead of the monsoons.',
      targetZone: 'All Zones',
      status: CampaignStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      requiredSkills: ['Community Outreach', 'Logistics'],
      targetVolunteers: 100,
      enrolledVolunteers: 45,
      progressPercentage: 45,
    ),
    Campaign(
      id: 'c2',
      title: 'Mega Blood Donation Camp',
      description: 'Weekend blood donation drive across 5 major hospitals.',
      targetZone: 'Central',
      status: CampaignStatus.planning,
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      requiredSkills: ['Medical', 'Coordination'],
      targetVolunteers: 30,
      enrolledVolunteers: 12,
      progressPercentage: 40,
    ),
  ];
}

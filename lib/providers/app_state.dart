import 'package:flutter/material.dart';
import 'package:smart_resource_alloc/models/need.dart';
import 'package:smart_resource_alloc/models/volunteer.dart';
import 'package:smart_resource_alloc/models/campaign.dart';
import 'package:smart_resource_alloc/data/mock_data.dart';

class AppState extends ChangeNotifier {
  List<Need> _needs = MockData.needs;
  List<Volunteer> _volunteers = MockData.volunteers;
  List<Campaign> _campaigns = MockData.campaigns;

  // Active Volunteer State
  String _currentVolunteerName = 'Sarah Jenkins';
  String _currentVolunteerZone = 'Koramangala Zone';

  // Active Admin State
  String _currentAdminName = 'Main HQ Admin';
  String _currentAdminEmail = 'admin@smartalloc.org';

  String get currentVolunteerName => _currentVolunteerName;
  String get currentVolunteerZone => _currentVolunteerZone;
  String get currentAdminName => _currentAdminName;
  String get currentAdminEmail => _currentAdminEmail;

  void updateAdminProfile(String name, String email) {
    _currentAdminName = name;
    _currentAdminEmail = email;
    notifyListeners();
  }

  void updateVolunteerProfile(String name, String zone) {
    _currentVolunteerName = name;
    _currentVolunteerZone = zone;
    notifyListeners();
  }

  void addVolunteer(String name, String zone, List<String> skills) {
    final newId = 'VOL-800\${_volunteers.length + 1}';
    final newVolunteer = Volunteer(
      id: newId,
      name: name,
      skills: skills,
      status: VolunteerStatus.available,
      lastKnownLocation: MockData.bangaloreCenter,
      baseZone: zone,
      rating: 5.0,
      tasksCompleted: 0,
    );
    _volunteers.add(newVolunteer);
    _currentVolunteerName = name;
    _currentVolunteerZone = zone;
    notifyListeners();
  }

  List<Need> get needs => _needs;
  List<Volunteer> get volunteers => _volunteers;
  List<Campaign> get campaigns => _campaigns;

  List<Need> get activeNeeds => _needs.where((n) => n.status != NeedStatus.resolved).toList();
  List<Need> get criticalNeeds => _needs.where((n) => n.urgencyScore >= 8 && n.status == NeedStatus.open).toList();

  int get availableVolunteersCount => _volunteers.where((v) => v.status == VolunteerStatus.available).length;
  int get activeVolunteersCount => _volunteers.where((v) => v.status == VolunteerStatus.busy).length;

  void markNeedResolved(String id) {
    var index = _needs.indexWhere((n) => n.id == id);
    if (index != -1) {
      _needs[index] = Need(
        id: _needs[index].id,
        title: _needs[index].title,
        description: _needs[index].description,
        category: _needs[index].category,
        urgencyScore: _needs[index].urgencyScore,
        location: _needs[index].location,
        zoneName: _needs[index].zoneName,
        status: NeedStatus.resolved,
        reportedAt: _needs[index].reportedAt,
        requiredSkills: _needs[index].requiredSkills,
        assignedVolunteerId: _needs[index].assignedVolunteerId,
      );
      notifyListeners();
    }
  }

  void assignVolunteer(String needId, String volunteerId) {
    var nIndex = _needs.indexWhere((n) => n.id == needId);
    var vIndex = _volunteers.indexWhere((v) => v.id == volunteerId);

    if (nIndex != -1 && vIndex != -1) {
      _needs[nIndex] = Need(
        id: _needs[nIndex].id,
        title: _needs[nIndex].title,
        description: _needs[nIndex].description,
        category: _needs[nIndex].category,
        urgencyScore: _needs[nIndex].urgencyScore,
        location: _needs[nIndex].location,
        zoneName: _needs[nIndex].zoneName,
        status: NeedStatus.inProgress,
        reportedAt: _needs[nIndex].reportedAt,
        requiredSkills: _needs[nIndex].requiredSkills,
        assignedVolunteerId: volunteerId,
      );
      
      _volunteers[vIndex] = Volunteer(
          id: _volunteers[vIndex].id,
          name: _volunteers[vIndex].name,
          skills: _volunteers[vIndex].skills,
          status: VolunteerStatus.busy,
          lastKnownLocation: _volunteers[vIndex].lastKnownLocation,
          baseZone: _volunteers[vIndex].baseZone,
          rating: _volunteers[vIndex].rating,
          tasksCompleted: _volunteers[vIndex].tasksCompleted,
      );

      notifyListeners();
    }
  }
}

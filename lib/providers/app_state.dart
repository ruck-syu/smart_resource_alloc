import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_resource_alloc/models/need.dart';
import 'package:smart_resource_alloc/models/volunteer.dart';
import 'package:smart_resource_alloc/models/campaign.dart';
import 'package:smart_resource_alloc/models/task.dart';
import 'package:smart_resource_alloc/models/heatmap_data.dart';
import 'package:smart_resource_alloc/data/mock_data.dart';
import 'package:smart_resource_alloc/services/api_service.dart';
import 'package:smart_resource_alloc/services/auth_service.dart';

/// Central application state with API-backed data fetching.
///
/// Falls back to mock data when the API is unreachable or returns errors,
/// providing offline resilience and a seamless dev experience.
class AppState extends ChangeNotifier {
  final ApiService _api;
  final AuthService _auth;

  // ── Data ──────────────────────────────────────────────────────────
  List<Need> _needs = [];
  List<Volunteer> _volunteers = [];
  List<Campaign> _campaigns = MockData.campaigns; // Campaigns stay mock for now
  List<Task> _tasks = [];
  HeatmapResponse? _heatmapResponse;

  // ── Loading / Error states ────────────────────────────────────────
  bool _isLoadingNeeds = false;
  bool _isLoadingVolunteers = false;
  bool _isLoadingTasks = false;
  bool _isLoadingHeatmap = false;
  String? _lastError;

  // ── Dashboard stats ───────────────────────────────────────────────
  Map<String, dynamic> _volunteerStats = {};
  Map<String, dynamic> _needStats = {};

  // ── User Profile State ────────────────────────────────────────────
  String _currentVolunteerName = 'Sarah Jenkins';
  String _currentVolunteerZone = 'Koramangala Zone';
  String _currentAdminName = 'Main HQ Admin';
  String _currentAdminEmail = 'admin@smartalloc.org';

  AppState(this._api, this._auth) {
    // Initialization without mock data
  }

  // ── Getters ───────────────────────────────────────────────────────

  ApiService get api => _api;
  AuthService get auth => _auth;

  List<Need> get needs => _needs;
  List<Volunteer> get volunteers => _volunteers;
  List<Campaign> get campaigns => _campaigns;
  List<Task> get tasks => _tasks;
  HeatmapResponse? get heatmapResponse => _heatmapResponse;

  bool get isLoadingNeeds => _isLoadingNeeds;
  bool get isLoadingVolunteers => _isLoadingVolunteers;
  bool get isLoadingTasks => _isLoadingTasks;
  bool get isLoadingHeatmap => _isLoadingHeatmap;
  String? get lastError => _lastError;

  Map<String, dynamic> get volunteerStats => _volunteerStats;
  Map<String, dynamic> get needStats => _needStats;

  String get currentVolunteerName => _currentVolunteerName;
  String get currentVolunteerZone => _currentVolunteerZone;
  String get currentAdminName => _currentAdminName;
  String get currentAdminEmail => _currentAdminEmail;

  List<Need> get activeNeeds =>
      _needs.where((n) => n.status != NeedStatus.resolved && n.status != NeedStatus.closed).toList();
  List<Need> get criticalNeeds =>
      _needs.where((n) => n.urgencyScore >= 8 && n.status == NeedStatus.open).toList();

  int get availableVolunteersCount =>
      _volunteers.where((v) => v.status == VolunteerStatus.available).length;
  int get activeVolunteersCount =>
      _volunteers.where((v) => v.status == VolunteerStatus.busy).length;

  List<Task> get activeTasks =>
      _tasks.where((t) => t.isActive).toList();
  List<Task> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  // ── Profile Updates (local) ───────────────────────────────────────

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

  // ── API-Backed Data Fetching ──────────────────────────────────────

  /// Fetch needs from the API. Falls back to mock data on error.
  Future<void> fetchNeeds({String? zone, String? category, int? minUrgency}) async {
    _isLoadingNeeds = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _api.getNeeds(
        zone: zone,
        category: category,
        minUrgency: minUrgency,
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          _needs = data
              .map((e) => Need.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('fetchNeeds failed, using mock data: $e');
      // Keep existing data (mock or previously fetched)
    }

    _isLoadingNeeds = false;
    notifyListeners();
  }

  /// Fetch volunteers from the API.
  Future<void> fetchVolunteers({String? status, String? skill}) async {
    _isLoadingVolunteers = true;
    notifyListeners();

    try {
      final response = await _api.getVolunteers(status: status, skill: skill);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          _volunteers = data
              .map((e) => Volunteer.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('fetchVolunteers failed: $e');
      _lastError = 'Failed to fetch volunteers';
      _volunteers = []; // clear volunteers on error
    }

    _isLoadingVolunteers = false;
    notifyListeners();
  }

  /// Fetch tasks for the current user from the API.
  Future<void> fetchTasks({String? volunteerId, String? status}) async {
    _isLoadingTasks = true;
    notifyListeners();

    try {
      final response = await _api.getTasks(
        volunteerId: volunteerId,
        status: status,
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          _tasks = data
              .map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('fetchTasks failed: $e');
    }

    _isLoadingTasks = false;
    notifyListeners();
  }

  /// Fetch heatmap data from the API.
  Future<void> fetchHeatmapData() async {
    _isLoadingHeatmap = true;
    notifyListeners();

    try {
      final response = await _api.getHeatmapData();
      if (response['success'] == true && response['data'] != null) {
        _heatmapResponse = HeatmapResponse.fromJson(
            response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('fetchHeatmapData failed: $e');
    }

    _isLoadingHeatmap = false;
    notifyListeners();
  }

  /// Fetch dashboard stats (admin only).
  Future<void> fetchDashboardStats() async {
    try {
      final volStats = await _api.getVolunteerStats();
      if (volStats['success'] == true && volStats['data'] != null) {
        _volunteerStats = volStats['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('fetchVolunteerStats failed: $e');
    }

    try {
      final nStats = await _api.getNeedStats();
      if (nStats['success'] == true && nStats['data'] != null) {
        _needStats = nStats['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('fetchNeedStats failed: $e');
    }

    notifyListeners();
  }

  // ── Dispatch Actions ──────────────────────────────────────────────

  /// Trigger smart dispatch for a need.
  Future<Map<String, dynamic>?> triggerDispatch(String needId) async {
    try {
      final response = await _api.triggerDispatch(needId);
      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      }
      _lastError = response['error'] ?? 'Dispatch failed';
    } catch (e) {
      _lastError = 'Dispatch failed: $e';
      debugPrint(_lastError);
    }
    notifyListeners();
    return null;
  }

  /// Manually assign a volunteer to a need.
  Future<bool> assignVolunteerApi(String needId, String volunteerId) async {
    try {
      final response = await _api.manualAssign(needId, volunteerId);
      if (response['success'] == true) {
        // Also update local state
        assignVolunteer(needId, volunteerId);
        return true;
      }
      _lastError = response['error'] ?? 'Assignment failed';
    } catch (e) {
      _lastError = 'Assignment failed: $e';
      // Fall back to local assignment
      assignVolunteer(needId, volunteerId);
    }
    notifyListeners();
    return false;
  }

  /// Accept a task (volunteer action).
  Future<bool> acceptTask(String taskId) async {
    try {
      final response = await _api.updateTaskStatus(taskId, 'accepted');
      if (response['success'] == true) {
        final idx = _tasks.indexWhere((t) => t.id == taskId);
        if (idx != -1) {
          _tasks[idx] = _tasks[idx].copyWith(
            status: 'accepted',
            acceptedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('acceptTask failed: $e');
    }
    return false;
  }

  /// Complete a task and submit feedback.
  Future<bool> completeTask(
    String taskId, {
    required String outcome,
    String? feedback,
    double? volunteerRating,
  }) async {
    try {
      // Update status to completed
      await _api.updateTaskStatus(taskId, 'completed');
      // Submit feedback
      await _api.submitFeedback(
        taskId,
        outcome: outcome,
        feedback: feedback,
        volunteerRating: volunteerRating,
      );
      // Update local state
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _tasks[idx] = _tasks[idx].copyWith(
          status: 'completed',
          outcome: outcome,
          feedback: feedback,
          completedAt: DateTime.now(),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('completeTask failed: $e');
      return false;
    }
  }

  // ── Local State Mutations (backward compat + offline) ─────────────

  void addVolunteer(String name, String zone, List<String> skills) {
    final newId = _auth.uid ?? 'VOL-800${_volunteers.length + 1}';
    final newVolunteer = Volunteer(
      id: newId,
      name: name,
      skills: skills,
      status: VolunteerStatus.available,
      lastKnownLocation: const LatLng(12.9716, 77.5946), // Bangalore Center
      baseZone: zone,
      rating: 5.0,
      tasksCompleted: 0,
    );
    _volunteers.add(newVolunteer);
    _currentVolunteerName = name;
    _currentVolunteerZone = zone;

    // Also register on backend
    _api.registerVolunteer(newVolunteer.toJson()).catchError((e) {
      debugPrint('registerVolunteer API call failed: $e');
      return <String, dynamic>{};
    });

    notifyListeners();
  }

  void markNeedResolved(String id) {
    var index = _needs.indexWhere((n) => n.id == id);
    if (index != -1) {
      _needs[index] = _needs[index].copyWith(status: NeedStatus.resolved);

      // Also update on backend
      _api.updateNeed(id, {'status': 'resolved'}).catchError((e) {
        debugPrint('updateNeed API call failed: $e');
        return <String, dynamic>{};
      });

      notifyListeners();
    }
  }

  void assignVolunteer(String needId, String volunteerId) {
    var nIndex = _needs.indexWhere((n) => n.id == needId);
    var vIndex = _volunteers.indexWhere((v) => v.id == volunteerId);

    if (nIndex != -1 && vIndex != -1) {
      _needs[nIndex] = _needs[nIndex].copyWith(
        status: NeedStatus.inProgress,
        assignedVolunteerId: volunteerId,
      );

      _volunteers[vIndex] = _volunteers[vIndex].copyWith(
        status: VolunteerStatus.busy,
      );

      notifyListeners();
    }
  }

  /// Create a need both locally and on the API.
  Future<bool> createNeed(Map<String, dynamic> data) async {
    try {
      final response = await _api.createNeed(data);
      if (response['success'] == true && response['data'] != null) {
        final newNeed =
            Need.fromJson(response['data'] as Map<String, dynamic>);
        _needs.insert(0, newNeed);
        notifyListeners();
        
        // AUTO-DISPATCH LOGIC: If urgency is 8 or higher, trigger matching engine
        if (newNeed.urgencyScore >= 8) {
          debugPrint('High urgency detected. Auto-dispatching...');
          await triggerDispatch(newNeed.id);
        }
        
        return true;
      }
    } catch (e) {
      debugPrint('createNeed failed: $e');
    }
    return false;
  }

  /// Update volunteer profile on the API.
  Future<bool> updateVolunteerApi(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.updateVolunteer(id, data);
      if (response['success'] == true) {
        // Refresh locally
        final idx = _volunteers.indexWhere((v) => v.id == id);
        if (idx != -1 && response['data'] != null) {
          _volunteers[idx] =
              Volunteer.fromJson(response['data'] as Map<String, dynamic>);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('updateVolunteer failed: $e');
    }
    return false;
  }

  /// Toggle volunteer availability status on the API.
  Future<bool> toggleVolunteerStatusApi(String id, String status) async {
    try {
      final response = await _api.toggleVolunteerStatus(id, status);
      if (response['success'] == true) {
        final idx = _volunteers.indexWhere((v) => v.id == id);
        if (idx != -1) {
          final newStatus = status == 'active'
              ? VolunteerStatus.available
              : status == 'busy'
                  ? VolunteerStatus.busy
                  : VolunteerStatus.offline;
          _volunteers[idx] = _volunteers[idx].copyWith(status: newStatus);
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('toggleVolunteerStatus failed: $e');
    }
    return false;
  }
}

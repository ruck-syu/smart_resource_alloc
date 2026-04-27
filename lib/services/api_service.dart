import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_resource_alloc/services/auth_service.dart';

/// Central API client for all 4 backend micro-services.
///
/// Every request automatically attaches the Firebase JWT token
/// via [AuthService]. Falls back gracefully when auth is unavailable.
class ApiService {
  static final Map<String, String> _bases = {
    'ingestion': dotenv.env['INGESTION_URL'] ?? '',
    'volunteer': dotenv.env['VOLUNTEER_URL'] ?? '',
    'needs': dotenv.env['NEEDS_URL'] ?? '',
    'dispatch': dotenv.env['DISPATCH_URL'] ?? '',
  };

  final AuthService _auth;

  ApiService(this._auth);

  // ── helpers ───────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    try {
      final token = await _auth.getIdToken();
      if (token != null) {
        return {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
      }
    } catch (_) {}
    return {'Content-Type': 'application/json'};
  }

  Future<Map<String, dynamic>> _get(String service, String path,
      {Map<String, String>? queryParams}) async {
    final uri =
        Uri.parse('${_bases[service]}$path').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(
      String service, String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${_bases[service]}$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _put(
      String service, String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('${_bases[service]}$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patch(
      String service, String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('${_bases[service]}$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  VOLUNTEER SERVICE
  // ═══════════════════════════════════════════════════════════════════

  /// POST /volunteers — Register a new volunteer
  Future<Map<String, dynamic>> registerVolunteer(
      Map<String, dynamic> data) async {
    return _post('volunteer', '/volunteers', data);
  }

  /// GET /volunteers — List all volunteers with optional filters
  Future<Map<String, dynamic>> getVolunteers({
    String? status,
    String? skill,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;
    if (skill != null) params['skill'] = skill;
    return _get('volunteer', '/volunteers', queryParams: params);
  }

  /// GET /volunteers/:id — Get volunteer profile
  Future<Map<String, dynamic>> getVolunteer(String id) async {
    return _get('volunteer', '/volunteers/$id');
  }

  /// PUT /volunteers/:id — Update volunteer profile
  Future<Map<String, dynamic>> updateVolunteer(
      String id, Map<String, dynamic> data) async {
    return _put('volunteer', '/volunteers/$id', data);
  }

  /// PATCH /volunteers/:id/status — Toggle volunteer status
  Future<Map<String, dynamic>> toggleVolunteerStatus(
      String id, String status) async {
    return _patch('volunteer', '/volunteers/$id/status', {'status': status});
  }

  /// GET /volunteers/search/nearby — Find volunteers near a location
  Future<Map<String, dynamic>> getNearbyVolunteers(
    double lat,
    double lng, {
    double radius = 10,
    String? skill,
  }) async {
    final params = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radius.toString(),
    };
    if (skill != null) params['skill'] = skill;
    return _get('volunteer', '/volunteers/search/nearby', queryParams: params);
  }

  /// GET /volunteers/stats/summary — Dashboard stats (admin only)
  Future<Map<String, dynamic>> getVolunteerStats() async {
    return _get('volunteer', '/volunteers/stats/summary');
  }

  // ═══════════════════════════════════════════════════════════════════
  //  NEEDS SERVICE
  // ═══════════════════════════════════════════════════════════════════

  /// POST /needs — Create a new community need
  Future<Map<String, dynamic>> createNeed(
      Map<String, dynamic> data) async {
    return _post('needs', '/needs', data);
  }

  /// GET /needs — List needs with filters
  Future<Map<String, dynamic>> getNeeds({
    String? zone,
    String? category,
    String? status,
    int? minUrgency,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (zone != null) params['zone'] = zone;
    if (category != null) params['category'] = category;
    if (status != null) params['status'] = status;
    if (minUrgency != null) params['minUrgency'] = minUrgency.toString();
    return _get('needs', '/needs', queryParams: params);
  }

  /// GET /needs/:id — Get need details
  Future<Map<String, dynamic>> getNeed(String id) async {
    return _get('needs', '/needs/$id');
  }

  /// PUT /needs/:id — Update a need (admin only)
  Future<Map<String, dynamic>> updateNeed(
      String id, Map<String, dynamic> data) async {
    return _put('needs', '/needs/$id', data);
  }

  /// PATCH /needs/:id/urgency — Update urgency score (admin only)
  Future<Map<String, dynamic>> updateUrgency(
      String id, int urgencyScore) async {
    return _patch(
        'needs', '/needs/$id/urgency', {'urgencyScore': urgencyScore});
  }

  /// GET /needs/heatmap/data — Heatmap data for maps
  Future<Map<String, dynamic>> getHeatmapData() async {
    return _get('needs', '/needs/heatmap/data');
  }

  /// GET /needs/stats/summary — Dashboard stats (admin only)
  Future<Map<String, dynamic>> getNeedStats() async {
    return _get('needs', '/needs/stats/summary');
  }

  // ═══════════════════════════════════════════════════════════════════
  //  DISPATCH SERVICE
  // ═══════════════════════════════════════════════════════════════════

  /// POST /dispatch — Trigger smart matching for a need
  Future<Map<String, dynamic>> triggerDispatch(String needId) async {
    return _post('dispatch', '/dispatch', {'needId': needId});
  }

  /// POST /dispatch/assign — Manually assign a volunteer to a need
  Future<Map<String, dynamic>> manualAssign(
      String needId, String volunteerId) async {
    return _post('dispatch', '/dispatch/assign', {
      'needId': needId,
      'volunteerId': volunteerId,
    });
  }

  /// GET /tasks — List tasks (volunteer sees own, admin sees all)
  Future<Map<String, dynamic>> getTasks({
    String? volunteerId,
    String? needId,
    String? status,
    int limit = 20,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (volunteerId != null) params['volunteerId'] = volunteerId;
    if (needId != null) params['needId'] = needId;
    if (status != null) params['status'] = status;
    return _get('dispatch', '/tasks', queryParams: params);
  }

  /// GET /tasks/:id — Get task details
  Future<Map<String, dynamic>> getTask(String id) async {
    return _get('dispatch', '/tasks/$id');
  }

  /// PATCH /tasks/:id/status — Update task status
  Future<Map<String, dynamic>> updateTaskStatus(
      String taskId, String status) async {
    return _patch(
        'dispatch', '/tasks/$taskId/status', {'status': status});
  }

  /// POST /tasks/:id/feedback — Submit outcome feedback
  Future<Map<String, dynamic>> submitFeedback(
    String taskId, {
    required String outcome,
    String? feedback,
    double? volunteerRating,
  }) async {
    final body = <String, dynamic>{'outcome': outcome};
    if (feedback != null) body['feedback'] = feedback;
    if (volunteerRating != null) body['volunteerRating'] = volunteerRating;
    return _post('dispatch', '/tasks/$taskId/feedback', body);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  INGESTION SERVICE
  // ═══════════════════════════════════════════════════════════════════

  /// POST /ingest — Submit data metadata for processing
  Future<Map<String, dynamic>> ingestData(
      Map<String, dynamic> data) async {
    return _post('ingestion', '/ingest', data);
  }

  /// POST /upload — Upload a file (multipart)
  Future<Map<String, dynamic>> uploadFile(
    List<int> fileBytes,
    String fileName, {
    String? sourceType,
    String? zone,
    String? organizationId,
  }) async {
    final uri = Uri.parse('${_bases['ingestion']}/upload');
    final request = http.MultipartRequest('POST', uri);

    // Auth header
    try {
      final token = await _auth.getIdToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));

    if (sourceType != null) request.fields['sourceType'] = sourceType;
    if (zone != null) request.fields['zone'] = zone;
    if (organizationId != null) {
      request.fields['organizationId'] = organizationId;
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// POST /upload-url — Get a direct upload signed URL
  Future<Map<String, dynamic>> getUploadUrl(
    String fileName,
    String contentType, {
    String? organizationId,
  }) async {
    final body = <String, dynamic>{
      'fileName': fileName,
      'contentType': contentType,
    };
    if (organizationId != null) body['organizationId'] = organizationId;
    return _post('ingestion', '/upload-url', body);
  }

  /// POST /batch — Upload CSV batch (multipart)
  Future<Map<String, dynamic>> batchUpload(
    List<int> csvBytes,
    String fileName, {
    String? organizationId,
    String? zone,
  }) async {
    final uri = Uri.parse('${_bases['ingestion']}/batch');
    final request = http.MultipartRequest('POST', uri);

    try {
      final token = await _auth.getIdToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      csvBytes,
      filename: fileName,
    ));

    if (organizationId != null) {
      request.fields['organizationId'] = organizationId;
    }
    if (zone != null) request.fields['zone'] = zone;

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HEALTH CHECK
  // ═══════════════════════════════════════════════════════════════════

  /// Check if a specific service is healthy
  Future<bool> checkHealth(String service) async {
    try {
      final res =
          await http.get(Uri.parse('${_bases[service]}/health'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['status'] == 'healthy';
      }
    } catch (_) {}
    return false;
  }
}

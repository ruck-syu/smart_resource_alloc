import 'package:hive_flutter/hive_flutter.dart';

class OfflineStorageService {
  static const String _boxName = 'pending_reports';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  static Box<Map<dynamic, dynamic>> get _box => Hive.box<Map<dynamic, dynamic>>(_boxName);

  static Future<void> saveReport(Map<String, dynamic> reportData) async {
    reportData['timestamp'] = DateTime.now().toIso8601String();
    reportData['status'] = 'Pending';
    await _box.add(reportData);
  }

  static List<Map<dynamic, dynamic>> getPendingReports() {
    return _box.values
        .where((r) => r['status'] == 'Pending')
        .toList()
        .cast<Map<dynamic, dynamic>>();
  }

  static int get pendingCount =>
      _box.values.where((r) => r['status'] == 'Pending').length;

  static Future<void> markAsSynced(int key) async {
    final report = _box.get(key);
    if (report != null) {
      report['status'] = 'Synced';
      await _box.put(key, report);
    }
  }

  static Future<void> markAsFailed(int key, String error) async {
    final report = _box.get(key);
    if (report != null) {
      report['status'] = 'Failed';
      report['syncError'] = error;
      await _box.put(key, report);
    }
  }

  /// Get all reports with their Hive keys for individual sync operations.
  static Map<dynamic, Map<dynamic, dynamic>> getPendingReportsWithKeys() {
    final result = <dynamic, Map<dynamic, dynamic>>{};
    for (var i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final value = _box.get(key);
      if (value != null && value['status'] == 'Pending') {
        result[key] = value;
      }
    }
    return result;
  }

  static Future<void> clearUploadedReports() async {
    // In a real app we would check which ones are uploaded successfully
    final keysToRemove = <dynamic>[];
    for (var i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final value = _box.get(key);
      if (value != null && value['status'] == 'Synced') {
        keysToRemove.add(key);
      }
    }
    await _box.deleteAll(keysToRemove);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}

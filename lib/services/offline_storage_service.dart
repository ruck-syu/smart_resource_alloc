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
    return _box.values.toList().cast<Map<dynamic, dynamic>>();
  }

  static Future<void> clearUploadedReports() async {
    // In a real app we would check which ones are uploaded successfully
    await _box.clear();
  }
}
